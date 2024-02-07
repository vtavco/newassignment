import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:newassignment/sql_helper.dart';


List<Map<String, dynamic>> _journals = [];
List<Map<String, dynamic>> _journalsCart = [];
List<String> myTitle = ["Home", "History", "Cart"];
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Widget> widgetList = [HomePage(), HistoryPage(), CartPage()];

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(myTitle[currentIndex]),
        ),
        body: widgetList[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Cart"),
          ],
          currentIndex: currentIndex,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Random random = new Random();
  final url = "https://dog.ceo/api/breeds/image/random";
  String myMessage = "";
  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    final cartdata = await SQLHelper.getItemsFromCart();
    setState(() {
      _journals = data;
      _journalsCart = cartdata;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    final url = "https://dog.ceo/api/breeds/image/random";
    fetchPost();
    print("====================" +
        _journals.length.toString() +
        "=====================");
    if (myMessage != "") {
      _addItem();
    } else if (myMessage == "") {
      Center(
        child: CircularProgressIndicator(),
      );
    }
    _refreshJournals(); // Loading the diary when the app starts
    print(_journals.length);
  }



  void fetchPost() async {
    try {
      final response = await get(Uri.parse(url));
      final jsonData = jsonDecode(response.body);

      setState(() {
        myMessage = jsonData["message"];
        print(myMessage);
        if (myMessage != "") {
                _addItem();
              } else if (myMessage == "") {
                Center(
                  child: CircularProgressIndicator(),
                );
              } 
      });
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<void> _addItem() async {
    int randomNumber = random.nextInt(10); // from 0 upto 99 included
    await SQLHelper.createItem(myMessage, randomNumber.toString() + " Rs");
    _refreshJournals();
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   fetchPost();
  // }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            margin: EdgeInsets.only(top: 100),
            child: myMessage.isEmpty
                ? Container(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Center(child: CircularProgressIndicator())),
                  )
                : Image.network(
                    myMessage,
                  ),
          ),
          SizedBox(
            height: 50,
          ),
          ElevatedButton(
            child: Text("get"),
            onPressed: () {
              fetchPost();
              print("===================" +
                  _journals.length.toString() +
                  "=====================");
              
            },
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  void _refreshJournalscart() async {
    final cartdata = await SQLHelper.getItemsFromCart();
    setState(() {
      _journalsCart = cartdata;
    });
  }

  Future<void> _addItemToCart(String imageUrl, String cost) async {
    await SQLHelper.createItemCart(imageUrl, cost + " Rs");
    _refreshJournalscart();
  }



  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 85, 178, 255),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Container(
                      color: Colors.black,
                      margin: EdgeInsets.all(10),
                      child: Image.network(
                        _journals[index]['imageUrl'],
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
                  Text(
                    "Price : " + _journals[index]['cost'],
                  )
                ],
              ),
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      _addItemToCart(_journals[index]['imageUrl'],
                          _journals[index]['cost']);
                      print(_journalsCart.length.toString() + " carts");
                    },
                    child: Text("Add to cart"),
                  ))
            ])),
        itemCount: _journals.length,
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState(); // Loading the diary when the app starts
    print(_journalsCart.length);
  }
void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    final cartdata = await SQLHelper.getItemsFromCart();
    setState(() {
      _journals = data;
      _journalsCart = cartdata;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _journalsCart.isEmpty ? Center(child: Text("Empty Cart"),) : ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 85, 178, 255),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Container(
                      color: Colors.black,
                      margin: EdgeInsets.all(10),
                      child: Image.network(
                        _journalsCart[index]['imageUrl'],
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "Price : " + _journalsCart[index]['cost'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(onPressed: () {setState(() {
                        SQLHelper.deleteItemFromCart(_journalsCart[index]["id"]);
                        _refreshJournals();
                      });}, child: Text("Delete"))
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        itemCount: _journalsCart.length,
      ),
    );
  }
}
