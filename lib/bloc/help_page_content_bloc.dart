import 'dart:convert';

import 'package:http/http.dart';
import 'package:nextdoorpartner/bloc/bloc_interface.dart';
import 'package:nextdoorpartner/models/help_model.dart';
import 'package:nextdoorpartner/resources/api_response.dart';
import 'package:nextdoorpartner/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

///Bloc for HelpPageContent
class HelpPageContentBloc implements BlocInterface {
  final _repository = Repository();
  var _helpPageContentFetcher = PublishSubject<ApiResponse<String>>();
  Stream<ApiResponse<String>> get helpPageStream =>
      _helpPageContentFetcher.stream;

  ///Gets content according to what was chosen on helpPage
  ///It Content is received according to index number
  getContent(int index) async {
    try {
      Response response = await _repository.getHelpContent(index);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _helpPageContentFetcher.sink
            .add(ApiResponse.hasData('Fetched', data: jsonResponse['content']));
      } else {
        _helpPageContentFetcher.sink
            .add(ApiResponse.error(jsonResponse['message']));
      }
    } catch (e) {
      print(e.toString());
      _helpPageContentFetcher.sink.add(ApiResponse.error(e.toString()));
    }
  }

  @override
  void dispose() {
    _helpPageContentFetcher.close();
  }
}
