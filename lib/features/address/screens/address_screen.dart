import 'package:amazon_clone/common/widgets/custom_button.dart';
import 'package:amazon_clone/common/widgets/custom_textfield.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/features/address/services/address_services.dart';
import 'package:amazon_clone/features/payment/screens/payment_screen.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  static const String routeName = '/address';
  final String totalAmount;

  const AddressScreen({
    Key? key,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController flatBuildingController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController townCityController = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();

  String addressToBeUsed = "";
  List<PaymentItem> paymentItems = [];
  final AddressServices addressServices = AddressServices();

  @override
  void dispose() {
    super.dispose();
    flatBuildingController.dispose();
    areaController.dispose();
    pinCodeController.dispose();
    townCityController.dispose();
  }

  @override
  void initState() {
    super.initState();
    paymentItems.add(
      PaymentItem(
        amount: widget.totalAmount,
        label: 'Total Amount',
        status: PaymentItemStatus.final_price,
      ),
    );
  }

  void onApplePayResult(res) {
    if (Provider.of<UserProvider>(context, listen: false)
        .user
        .address
        .isEmpty) {
      addressServices.saveUserAddress(
          context: context, address: addressToBeUsed);
    }
    addressServices.placeOrder(
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
    );
  }

  void onGooglePayResult(res) {
    if (Provider.of<UserProvider>(context, listen: false)
        .user
        .address
        .isEmpty) {
      addressServices.saveUserAddress(
          context: context, address: addressToBeUsed);
    }
    addressServices.placeOrder(
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
    );
  }

  void payPressed(String addressFromProvider) {
    addressToBeUsed = "";
    bool isForm = flatBuildingController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        pinCodeController.text.isNotEmpty ||
        townCityController.text.isNotEmpty;

    if (isForm) {
      if (_addressFormKey.currentState!.validate()) {
        addressToBeUsed =
            '${flatBuildingController.text}, ${areaController.text}, ${townCityController.text} - ${pinCodeController.text}';
      } else {
        throw Exception('Please enter all the values!');
      }
    } else if (addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
    } else {
      showSnackBar(context, 'ERROR');
    }
  }

  void navigateToPaymentScreen() {
    Navigator.pushNamed(context, PaymentScreen.routeName, arguments: {
      'totalAmount': widget.totalAmount,
      'address': addressToBeUsed,
    });
  }

  void payNow(String addressFromProvider) {
    payPressed(addressFromProvider);
    navigateToPaymentScreen();
  }

  @override
  Widget build(BuildContext context) {
    var address = context.watch<UserProvider>().user.address;
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
                if (address.isNotEmpty)
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'OR',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                Form(
                  key: _addressFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: flatBuildingController,
                        hintText: "Flat, House no, Building",
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: areaController,
                        hintText: "Area, Street",
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: pinCodeController,
                        hintText: "Pincode",
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: townCityController,
                        hintText: "Town/City",
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ApplePayButton(
                  onPressed: () => payPressed(address),
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(top: 15),
                  style: ApplePayButtonStyle.whiteOutline,
                  type: ApplePayButtonType.buy,
                  paymentConfigurationAsset: 'applepay.json',
                  onPaymentResult: onApplePayResult,
                  paymentItems: paymentItems,
                ),
                // const SizedBox(height: 10),
                // GooglePayButton(
                //   onPressed: () => payPressed(address),
                //   width: double.infinity,
                //   height: 50,
                //   margin: const EdgeInsets.only(top: 15),
                //   style: GooglePayButtonStyle.black,
                //   type: GooglePayButtonType.buy,
                //   paymentConfigurationAsset: 'gpay.json',
                //   onPaymentResult: onGooglePayResult,
                //   paymentItems: paymentItems,
                //   loadingIndicator: const Center(
                //     child: CircularProgressIndicator(),
                //   ),
                // ),
                const SizedBox(height: 10),
                CustomButton(
                  // width: double.infinity,
                  // height: 50,
                  // margin: const EdgeInsets.only(top: 15),
                  text: 'Pay Now',
                  onTap: () => payNow(address),
                ),
              ],
            ),
          ),
        ));
  }
}
