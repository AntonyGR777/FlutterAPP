#include "flutter_window.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <shellapi.h>

#include <optional>
#include <string>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

namespace {

constexpr char kNotificationChannelName[] = "proyecto1/notificaciones";
constexpr UINT kNotificationIconId = 1;
constexpr UINT kNotificationCallbackMessage = WM_APP + 1;

std::wstring Utf8ToWide(const std::string& value) {
  if (value.empty()) {
    return L"";
  }

  const int size = MultiByteToWideChar(CP_UTF8, 0, value.c_str(), -1, nullptr, 0);
  if (size <= 0) {
    return L"";
  }

  std::wstring wide(size - 1, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, value.c_str(), -1, wide.data(), size);
  return wide;
}

std::wstring ReadStringArgument(
    const flutter::EncodableMap& arguments,
    const char* key,
    const wchar_t* fallback) {
  const auto iterator = arguments.find(flutter::EncodableValue(key));
  if (iterator == arguments.end()) {
    return fallback;
  }

  if (const auto* value = std::get_if<std::string>(&iterator->second)) {
    return Utf8ToWide(*value);
  }

  return fallback;
}

void CopyToNotifyField(wchar_t* destination, size_t destination_size,
                       const std::wstring& source) {
  wcsncpy_s(destination, destination_size, source.c_str(), _TRUNCATE);
}

void EnsureNotificationIcon(HWND hwnd) {
  NOTIFYICONDATA notify_data = {};
  notify_data.cbSize = sizeof(NOTIFYICONDATA);
  notify_data.hWnd = hwnd;
  notify_data.uID = kNotificationIconId;
  notify_data.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  notify_data.uCallbackMessage = kNotificationCallbackMessage;
  notify_data.hIcon =
      LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON));
  CopyToNotifyField(notify_data.szTip, ARRAYSIZE(notify_data.szTip), L"Proyecto1");

  Shell_NotifyIcon(NIM_ADD, &notify_data);
}

void ShowWindowsNotification(HWND hwnd, const std::wstring& title,
                             const std::wstring& message) {
  EnsureNotificationIcon(hwnd);

  NOTIFYICONDATA notify_data = {};
  notify_data.cbSize = sizeof(NOTIFYICONDATA);
  notify_data.hWnd = hwnd;
  notify_data.uID = kNotificationIconId;
  notify_data.uFlags = NIF_INFO;
  notify_data.dwInfoFlags = NIIF_INFO | NIIF_LARGE_ICON;
  notify_data.uTimeout = 10000;
  CopyToNotifyField(notify_data.szInfoTitle, ARRAYSIZE(notify_data.szInfoTitle),
                    title);
  CopyToNotifyField(notify_data.szInfo, ARRAYSIZE(notify_data.szInfo), message);

  Shell_NotifyIcon(NIM_MODIFY, &notify_data);
}

void CancelWindowsNotification(HWND hwnd) {
  NOTIFYICONDATA notify_data = {};
  notify_data.cbSize = sizeof(NOTIFYICONDATA);
  notify_data.hWnd = hwnd;
  notify_data.uID = kNotificationIconId;

  Shell_NotifyIcon(NIM_DELETE, &notify_data);
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  auto notification_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), kNotificationChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  notification_channel->SetMethodCallHandler(
      [hwnd = GetHandle()](const flutter::MethodCall<flutter::EncodableValue>& call,
                           std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                               result) {
        if (call.method_name() == "initialize") {
          EnsureNotificationIcon(hwnd);
          result->Success();
          return;
        }

        if (call.method_name() == "showNotification") {
          std::wstring title = L"Proyecto1";
          std::wstring message = L"Operacion completada";

          if (call.arguments()) {
            if (const auto* arguments =
                    std::get_if<flutter::EncodableMap>(call.arguments())) {
              title = ReadStringArgument(*arguments, "title", L"Proyecto1");
              message = ReadStringArgument(*arguments, "message",
                                           L"Operacion completada");
            }
          }

          ShowWindowsNotification(hwnd, title, message);
          result->Success();
          return;
        }

        if (call.method_name() == "cancelNotification") {
          CancelWindowsNotification(hwnd);
          result->Success();
          return;
        }

        result->NotImplemented();
      });

  notification_channel_ = std::move(notification_channel);
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  CancelWindowsNotification(GetHandle());

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
