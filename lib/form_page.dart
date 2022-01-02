import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final String _tokenAuth = '';
  final TextEditingController _inputTitle = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _path = '';
  String _filename = '';

  Future _postFormData() async {
    try {
      Map<String, String> requestBody = <String, String>{
        'title': _inputTitle.text,
      };
      Map<String, String> headers = <String, String>{
        'contentType': 'multipart/form-data',
        'Authorization': 'Bearer ' + _tokenAuth
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('https://jsonplaceholder.typicode.com/albums'))
        ..headers.addAll(headers)
        ..fields.addAll(requestBody);
      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath('gambar', _path);
      request.files.add(multipartFile);
      var response = await request.send();
      var res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        print('sukses');
      } else {
        print('error');
      }
    } on SocketException {
      print('no internet');
    } on HttpException {
      print('error');
    } on FormatException {
      print('error');
    }
  }

  void _onChangeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _path = file.path.toString();
        _filename = file.name.toString();
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('POST FORM DATA'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _inputTitle,
                    decoration: InputDecoration(
                      hintText: 'Judul',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          _onChangeFile();
                        },
                        icon: Icon(Icons.upload_file),
                        label: Text('Upload File')),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(_filename),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _postFormData();
                        }
                      },
                      child: Text('Submit'))
                ],
              ),
            ),
          ),
        ));
  }
}
