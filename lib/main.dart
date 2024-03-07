import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        fontFamily: 'Roboto', 
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('GST Bill Generator'),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController personNameController = TextEditingController();
  TextEditingController invoiceNumberController = TextEditingController();

  double totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
         
          TextFormField(
            controller: personNameController,
            decoration: InputDecoration(
              labelText: 'Person Name',
              border: OutlineInputBorder(),
            ),
          ),
            SizedBox(height: 16.0),
          TextFormField(
            controller: itemNameController,
            decoration: InputDecoration(
              labelText: 'Item Name',
              border: OutlineInputBorder(),
            ),
          ),
           SizedBox(height: 16.0),
          TextFormField(
            controller: invoiceNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Invoice Number',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: itemPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Item Price',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
          ),
        
          SizedBox(height: 20.0),
          Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Amount',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    '$totalAmount',
                    style: TextStyle(
                        fontSize: 24.0, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              _generateGSTBill();
              await _createPDF(); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), 
              ),
              elevation: 5, // Add elevation
            ),
            child: Text(
              'Generate GST Bill and Save as PDF',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateGSTBill() {
    String itemName = itemNameController.text;
    double itemPrice = double.parse(itemPriceController.text);
    int quantity = int.parse(quantityController.text);
    double total = itemPrice * quantity;
    double gst = total * 0.18; 
    double finalAmount = total + gst;

    setState(() {
      totalAmount = finalAmount;
    });
  }

  Future<void> _createPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(5),
            border: pw.Border.all(
              color: PdfColor.fromHex('#1976D2'),
              width: 2,
            ),
          ),
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('GST Bill',
                  style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1976D2'))),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${DateTime.now().toLocal()}',
                  style: pw.TextStyle(
                      fontSize: 16, color: PdfColor.fromHex('#757575'))),
              pw.SizedBox(height: 20),
              _buildTable(),
              pw.SizedBox(height: 20),
              pw.Text('Total Amount: $totalAmount',
                  style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1976D2'))),
            ],
          ),
        ),
      ),
    );
    final output = await getExternalStorageDirectory();
    final file = File("${output?.path}/Gst_bill.pdf");
    final pdfBytes = await pdf.save(); 
    await file.writeAsBytes(pdfBytes);
    // Share.shareFiles([file.path], text: 'Sharing GST Bill PDF');
  }

  pw.Widget _buildTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#1976D2')),
      children: [
         _buildTableRow('Person Name', personNameController.text),
        _buildTableRow('Item Name', itemNameController.text),
          _buildTableRow('Invoice Number', invoiceNumberController.text),
        _buildTableRow('Item Price', itemPriceController.text),
        _buildTableRow('Quantity', quantityController.text),
        _buildTableRow('GST (18%)', calculateGST().toStringAsFixed(2)),
      ],
    );
  }

  double calculateGST() {
    double itemPrice = double.parse(itemPriceController.text);
    int quantity = int.parse(quantityController.text);

    double total = itemPrice * quantity;
    double gst = total * 0.18;

    return gst;
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(8),
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1976D2'))),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(8),
          alignment: pw.Alignment.centerRight,
          child: pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 18, color: PdfColor.fromHex('#333333'))),
        ),
      ],
    );
  }
}
