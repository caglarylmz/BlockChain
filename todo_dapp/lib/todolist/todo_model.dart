import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class TodoModel extends ChangeNotifier {
  List<Task> todos = [];
  bool isLoading = true;

  final String _rpcUrl = "http://127.0.0.1:7545";
  final String _wsUrl = "ws://127.0.0.1:7545";

  final String _privateKey =
      "3f07c0aa2cb94f732041e001172702d7f77233876f11914e15adb80f4b5ab3cd";
  late Credentials _credentials;

  late Web3Client _client;
  late String _abiCode;
  late EthereumAddress _contractAdress;
  late EthereumAddress _ownAdress;
  late DeployedContract _contract;

  late ContractFunction _tasksLength;
  late ContractFunction _createTask;
  late ContractEvent _createTaskEvent;
  late ContractFunction _tasks;

  TodoModel() {
    initiateSetup();
  }

  initiateSetup() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString("dapp/build/contracts/TodoList.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAdress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    //print(_contractAdress);
  }

  Future<void> getCredentials() async {
    //credentials = await _client.credentialsFromPrivateKey(privateKey)
    _credentials = EthPrivateKey.fromHex(_privateKey);
    _ownAdress = await _credentials.extractAddress();
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "TodoList"), _contractAdress);
    _tasksLength = _contract.function("getTasksLength");
    _createTask = _contract.function("createTask");
    //_todos = _contract.function("todos");
    _tasks = _contract.function("tasks");
    _createTaskEvent = _contract.event("TaskCreated");
    getTodos();
  }

  getTodos() async {
    var resTasksLength = await _client
        .call(contract: _contract, function: _tasksLength, params: []);
    BigInt totalTask = resTasksLength[0];
    todos.clear();
    for (var i = 0; i < totalTask.toInt(); i++) {
      var temp = await _client.call(
          contract: _contract, function: _tasks, params: [BigInt.from(i)]);
      todos.add(Task(taskName: temp[0], isCompleted: temp[1]));
    }
    isLoading = false;
    notifyListeners();
  }

  addTask(String taskNameData) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _createTask,
            parameters: [taskNameData]));
    getTodos();
  }
}

class Task {
  String taskName;
  bool isCompleted;
  Task({
    required this.taskName,
    required this.isCompleted,
  });
}
