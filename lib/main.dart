import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String cep;
  var cidade;
  var temperatura;
  var tempoDescricao;
  var tempoAgora;
  var umidadeAr;
  var vento;

  Future getcep() async {
    http.Response response =
        await http.get("https://viacep.com.br/ws/$cep/json/");
    var results = jsonDecode(response.body);

    setState(() {
      this.cidade = results['localidade'];
    });

    this.getWeather();
  }

  Future getWeather() async {
    http.Response response = await http.get(
        "http://api.openweathermap.org/data/2.5/weather?q=$cidade&Brazil&appid=e8962427977895dc7b82576019a60ef1");
    var results = jsonDecode(response.body);

    setState(() {
      this.temperatura = results['main']['temp'];
      this.tempoDescricao = results['weather'][0]['description'];
      this.tempoAgora = results['weather'][0]['main'];
      this.umidadeAr = results['main']['humidity'];
      this.vento = results['wind']['speed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Previsão do tempo'),
        ),
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              key: _key,
              autovalidate: _validate,
              child: _formUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    return new Column(
      children: <Widget>[
        new TextFormField(
          decoration: new InputDecoration(hintText: 'CEP'),
          maxLength: 40,
          validator: _validarCEP,
          onSaved: (String val) {
            cep = val;
          },
        ),
        new SizedBox(height: 15.0),
        new RaisedButton(
          onPressed: _sendForm,
          child: new Text('Confirmar'),
        ),
        Container(
          color: Color.fromRGBO(252, 119, 183, 1.0),
          child: Text(
              tempoDescricao.toString() != null
                  ? 'Clima: ' + tempoDescricao.toString()
                  : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Color.fromRGBO(194, 119, 252, 1.0),
          child: Text(
              temperatura.toString().isNotEmpty != null
                  ? 'Temperatura: ' + temperatura.toString()
                  : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Color.fromRGBO(119, 252, 217, 1.0),
          child: Text(
              umidadeAr.toString() != null
                  ? 'Umidade Ar: ' + umidadeAr.toString()
                  : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Color.fromRGBO(242, 255, 156, 1.0),
          child: Text(
              tempoAgora.toString().isNotEmpty != null
                  ? 'Tempo agora: ' + tempoAgora.toString()
                  : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Color.fromRGBO(114, 99, 247, 1.0),
          child: Text(
            vento.toString().isNotEmpty != null
                ? 'Vento: ' + vento.toString()
                : "",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        ),
      ],
    );
  }

  String _validarCEP(String value) {
    String patttern = r'(^\d{8}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe a CEP";
    } else if (!regExp.hasMatch(value)) {
      return "O CEP deve conter apenas números";
    }
    return null;
  }

  _sendForm() {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      this.getcep();
    } else {
      setState(() {
        _validate = true;
      });
    }
  }
}
