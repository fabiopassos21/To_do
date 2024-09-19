import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // File
import 'dart:convert';
import 'dart:async';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  List lista = [];
  Map<String, dynamic> ultimoRemovido = Map();
  TextEditingController controller = TextEditingController();

  salvarTarefa() {
    String textoDigitado = controller.text;
    Map<String, dynamic> tarefa = Map();
    // CONBERTE A LISTA PARA JSON
    // criar dados
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      lista.add(tarefa);
    });
    controller.text = "";
  }

  salvarArquivo() async {
    var arquivo = await getFile();
    Map<String, dynamic> tarefa = Map();
    String dados = json.encode(lista);
    arquivo.writeAsString(dados); // pASSA O JSON e salva
    // print("meu caminho " + diretorio.path);
  }

  lararqruivo() async {
    try {
      final arquivo = await getFile();
      arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  @override
  void initState() {
    super.initState();
    lararqruivo().then((dados) {
      setState(() {
        lista = json.decode(dados);
      });
    });
  }

  Widget criarItemLista(context, index) {
    return Dismissible(
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          // remover a porra do item
          ultimoRemovido = lista[index];
          lista.removeAt(index);
          //snackbar

          salvarArquivo();
          final snackbar = SnackBar(
            content: Text("Tarefa removida !!"),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  //desfazer a operacao
                  setState(() {
                    lista.insert(index, ultimoRemovido);
                  });

                  salvarArquivo();
                }),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete, color: Colors.white),
            ],
          ),
        ),
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            CheckboxListTile(
                title: Text(
                  lista[index]['titulo'],
                  style: TextStyle(color: Colors.white),
                ),
                value: lista[index]['realizada'],
                controlAffinity: ListTileControlAffinity.leading,
                checkColor: Colors.white,
                activeColor: Color.fromRGBO(100, 27, 141, 9),
                tileColor: Color.fromRGBO(5, 24, 83, 9),
                checkboxShape: BeveledRectangleBorder(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onChanged: (valorAlterado) {
                  setState(() {
                    lista[index]['realizada'] = valorAlterado;
                    if (valorAlterado == true) {}
                  });
                  salvarArquivo();
                })
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    salvarArquivo();
    DateTime agora = DateTime.now();
    String dataFormatada = DateFormat('dd/MM/yyyy  ').format(agora);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(31, 246, 169,
                  1), // Corrigido o último parâmetro para opacidade entre 0 e 1
              Color.fromRGBO(2, 179, 246, 1),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 80, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Olá Bem-Vindo ',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Atividades de hoje: ' + dataFormatada,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: lista.length,
                itemBuilder: criarItemLista,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        elevation: 1,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Gravar item"),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: "Digite sua tarefa"),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Não"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        salvarTarefa();
                        Navigator.pop(context);
                      },
                      child: Text("Sim")),
                ],
              );
            },
          );
        },
        label: Icon(Icons.add),
      ),
    );
  }
}
