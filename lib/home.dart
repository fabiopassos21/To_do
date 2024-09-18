import 'package:flutter/material.dart';
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
    final item = lista[index]["titulo"];

    return Dismissible(
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          // remover a porra do item
          lista.removeAt(index);
          //snackbar

          //  salvarArquivo();
          final snackbar = SnackBar(content: Text("Tarefa removida !!"));

          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete, color: Colors.white),
            ],
          ),
        ),
        key: Key(item),
        child: CheckboxListTile(
            title: Text(lista[index]['titulo']),
            value: lista[index]['realizada'],
            onChanged: (valorAlterado) {
              setState(() {
                lista[index]['realizada'] = valorAlterado;
              });
              salvarArquivo();
            }));
  }

  @override
  Widget build(BuildContext context) {
    salvarArquivo();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manipulação",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              // Aqui o ListView ocupa o espaço restante
              child: ListView.builder(
                itemCount: lista.length,
                itemBuilder: criarItemLista,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 6,
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
