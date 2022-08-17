import 'package:amazon_clone/common/widgets/custom_button.dart';
import 'package:amazon_clone/common/widgets/custom_textfield.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/features/address/services/address_services.dart';
import 'package:amazon_clone/features/home/screens/home_screen.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  static const String routeName = '/payment';
  final String address;
  final String totalAmount;

  const PaymentScreen({
    Key? key,
    required this.address,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryMonthController = TextEditingController();
  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController securityCodeController = TextEditingController();
  final _paymentFormKey = GlobalKey<FormState>();
  final AddressServices addressServices = AddressServices();

  void payNow() {
    if (_paymentFormKey.currentState!.validate()) {
      if (Provider.of<UserProvider>(context, listen: false)
          .user
          .address
          .isEmpty) {
        addressServices.saveUserAddress(
            context: context, address: widget.address);
      }
      addressServices.placeOrder(
        context: context,
        address: widget.address,
        totalSum: double.parse(widget.totalAmount),
      );
      returnToHomeScreen();
    }
  }

  void returnToHomeScreen() {
    Navigator.pushNamed(context, HomeScreen.routeName);
  }

  @override
  void dispose() {
    super.dispose();
    cardNumberController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    securityCodeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Form(
                key: _paymentFormKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: cardNumberController,
                      hintText: "Credit Card Number",
                    ),
                    CustomTextField(
                      controller: expiryMonthController,
                      hintText: "Expiry Month",
                    ),
                    CustomTextField(
                      controller: expiryYearController,
                      hintText: "Expiry Year",
                    ),
                    CustomTextField(
                      controller: securityCodeController,
                      hintText: "Security Code",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              CustomButton(text: 'Pay Now', onTap: payNow),
            ],
          ),
        ),
      ),
    );
  }
}
