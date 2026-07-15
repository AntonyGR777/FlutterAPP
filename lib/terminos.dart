import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TerceraPagina extends StatelessWidget {
  TerceraPagina({super.key});
  final TextStyle stilo = TextStyle(color:Color.fromARGB(255, 248, 103, 6));

  @override
  Widget build(BuildContext context) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          'Cancelar',
          style: TextStyle(color: CupertinoColors.activeBlue),
        ),
      ),
      middle: const Text('terminossss'),
    ),
    child: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(50),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                      Text(
                        'Terminamos aqui',
                        style: stilo
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              padding: EdgeInsets.all(20),
            child:ElevatedButton(
              onPressed: () => debugPrint('a'),
              child: Text('AAAAAAAACEPTO'),
            ),
            ),
          ],
        ),
      ),
    ),
  );
}
}