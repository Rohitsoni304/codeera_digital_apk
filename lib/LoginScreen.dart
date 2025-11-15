import 'dart:convert';
import 'package:codeera_digital_apk/BottomBar.dart';
import 'package:codeera_digital_apk/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 🏠 import your actual home screen file here 👇
import 'HomeScreen.dart'; // ✅ replace with your actual path

class LoginWithOtpScreen extends StatefulWidget {
  const LoginWithOtpScreen({super.key});

  @override
  State<LoginWithOtpScreen> createState() => _LoginWithOtpScreenState();
}

class _LoginWithOtpScreenState extends State<LoginWithOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  /// 🔹 Send OTP API Call (with success message)
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${baseurl.url}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"number": phone}),
      );

      final data = jsonDecode(response.body);
      setState(() => _isLoading = false);
      print(data);

      if (response.statusCode == 200) {
        // ✅ Show message clearly with number
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] != null && data["message"].toString().isNotEmpty
                  ? data["message"]
                  : "OTP sent successfully to +91 $phone",
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        _showOtpBottomSheet(phone);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Something went wrong ❌"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// 🔹 Show OTP Bottom Sheet
  void _showOtpBottomSheet(String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => OTPBottomSheet(phone: phone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.07,
            vertical: size.height * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.07),

              // 🌟 Logo
              Center(
                child: Container(
                  height: size.height * 0.40,
                  width: size.width * 0.70,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/codeera-logo.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              const Text(
                "INNOVATE | AUTOMATE | SUCCEED",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: size.height * 0.04),
              const Text(
                "Login to continue with your phone number",
                style: TextStyle(color: Colors.black54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // 📞 Phone Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text(
                      "+91",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                          hintText: "Enter your phone number",
                          hintStyle: TextStyle(color: Colors.black38),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // 🚀 Continue Button
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : InkWell(
                onTap: _sendOtp,
                child: Container(
                  height: 55,
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3B1E9D),
                        Colors.purple,// Dark Blue-Purple shade
                       // Bright Purple
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),


              SizedBox(height: size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔢 OTP Bottom Sheet (enhanced)
/// 🔢 OTP Bottom Sheet (Responsive & Scrollable)
class OTPBottomSheet extends StatefulWidget {
  final String phone;
  const OTPBottomSheet({super.key, required this.phone});

  @override
  State<OTPBottomSheet> createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends State<OTPBottomSheet> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  bool _isVerifying = false;

  /// 🔹 Verify OTP API Call
  /// 🔹 Verify OTP API Call
  Future<void> _verifyOtp() async {
    String otp = _otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid 6-digit OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await http.post(
        Uri.parse("${baseurl.url}/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "number": widget.phone,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => _isVerifying = false);

      if (response.statusCode == 200 ) {
        // ✅ Save login state and token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
       // await prefs.setString("userNumber", widget.phone);
        print(response.body);
        // 🟢 Save token if available
        if (data.containsKey("token")) {
          await prefs.setString("authToken", data["token"]);
          print("✅ Token saved: ${data['token']}");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login successful ✅")),
        );

        // Navigate to HomeScreen
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 700),
              pageBuilder: (_, __, ___) => const Bottombar(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Invalid OTP ❌")),
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      builder: (_, controller) {

        return SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 30,
            left: size.width * 0.07,
            right: size.width * 0.07,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              // Drag indicator
              Container(

                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                "Enter OTP",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // 📱 Sent message
              Text(
                "OTP sent to +91 ${widget.phone}",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              // 🔢 OTP Boxes
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(6, (index) {
                  return _buildOtpBox(_otpControllers[index], index, size);
                }),
              ),

              const SizedBox(height: 40),

              // 🔘 Verify Button
              _isVerifying
                  ? const CircularProgressIndicator(color: Colors.green)
                  : InkWell(
                onTap: _verifyOtp,
                child: Container(
                  height: 50,
                  width: size.width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [ // Dark Blue - Purple
                        Color(0xFF7B2FF7),
                        Colors.purple// Bright Purple
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Verify OTP",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildOtpBox(TextEditingController controller, int index, Size size) {
    return Container(
      height: size.height * 0.065,
      width: size.width * 0.12,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26, width: 1.3),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [LengthLimitingTextInputFormatter(1)],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}