// part of 'view_de_pledge.dart';
//
// class ClientListProvider extends ProviderExtension {
//   bool isLoading = true;
//
//   List<ClientModel> dataList = [];
//
//   TextEditingController searchCtrl = TextEditingController();
//
//   HomeProvider get provider => Provider.of(Cnt.context, listen: false);
//
//   @override
//   void init({Map<String, dynamic>? map}) {
//     getApi();
//   }
//
//   @override
//   void reset() {
//     if (!provider.routeList.contains(EmPage.client)) {
//       isLoading = true;
//       dataList.clear();
//       searchCtrl.clear();
//     }
//   }
//
//   onChangeSearch() => getApi();
//
//   onSelectMenu(String value, ClientModel v) {
//     if (value == 'share') {
//       showClientShare(v);
//     }
//   }
//
//   getApi({bool isPagination = false}) {
//     Pagination p = STM.pagination(
//       list: isPagination ? dataList : [],
//     );
//     Api.call(
//       method: ApiMethod.post,
//       name: 'partner/client-list',
//       queryParameters: {
//         'limit': 10,
//         'pageNumber': p.page,
//       },
//       rawData: {
//         'filter': {
//           'name': searchCtrl.trim(),
//         },
//         'partnerLeadType':'offline',
//       },
//       onResponse: (v) {
//         try {
//           var result = responseFromJson(v);
//           if (result.status == 'success' && result.data != null) {
//             isLoading = false;
//             var list = clientFromJson(result.data);
//             if (p.isFirst) {
//               dataList = list;
//             } else {
//               dataList.addAll(list);
//             }
//           }
//         } catch (e, stackTrace) {
//           debugPrint('Error :: $e');
//           debugPrint('Stack Trace: $stackTrace');
//         }
//         notifyListeners();
//       },
//     );
//   }
// }
