import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/data/module/active_member_params.dart';
import 'package:m/data/module/login_params.dart';
import 'package:m/data/module/register_params.dart';
import 'package:m/data/services/user.dart';
import 'package:m/shared/widgets/button/primary_button.dart';
import 'dart:convert';

import 'package:m/shared/widgets/h1.dart';

enum LoginDialogStatus {
  login,
  register,
  active,
}

enum RegisterTerminal {
  web,
  android,
  ios,
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});
  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  LoginDialogStatus status = LoginDialogStatus.login;
  String get title => status == LoginDialogStatus.login
      ? '登录'.tr
      : status == LoginDialogStatus.register
          ? '注册'.tr
          : '激活账号'.tr;
  Icon get icon => status == LoginDialogStatus.login
      ? const Icon(Icons.login)
      : status == LoginDialogStatus.register
          ? const Icon(Icons.app_registration)
          : const Icon(Icons.check_circle);
  bool isLoginMode = true;
  final _formKey = GlobalKey<FormState>();

  int get registerTerminal =>
      RegisterTerminal.values.indexOf(GetPlatform.isAndroid
          ? RegisterTerminal.android
          : GetPlatform.isIOS
              ? RegisterTerminal.ios
              : RegisterTerminal.web);

  // 假设您的代码中已有以下控制器定义
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final TextEditingController _activeCodeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    UserService.to.getCaptchaImage();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // 渐变背影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StarThemeData.spacing),
      ),
      child: Container(
        padding: EdgeInsets.all(StarThemeData.spacing),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(StarThemeData.spacing),
          gradient: context.isDarkMode ? null : StarThemeData.dalogBgGradient,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    icon,
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                Row(
                  children: [
                    H1(title: title),
                    const Spacer(),
                    Obx(() => UserService.to.loginLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
                ...status == LoginDialogStatus.active
                    ? [
                        Text(
                          '账号注册后，邮箱会收到激活码，请登录注册的邮箱查看并激活账号'.tr,
                          style: const TextStyle(color: Colors.red),
                        )
                      ]
                    : [],
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  decoration: InputDecoration(labelText: '邮箱'.tr),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return '请输入有效的邮箱';
                    }
                    return null;
                  },
                ),
                ...status == LoginDialogStatus.active
                    ? [
                        const SizedBox(height: 16),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _activeCodeController,
                          decoration: InputDecoration(
                            labelText: '激活码'.tr,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入激活码';
                            }
                            return null;
                          },
                        ),
                      ]
                    : [
                        const SizedBox(height: 16),
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: '密码'.tr),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            if (value.length < 6) {
                              return '密码长度至少6位';
                            }
                            return null;
                          },
                        )
                      ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _captchaController,
                        decoration: InputDecoration(
                          labelText: '验证码'.tr,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入验证码';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        await UserService.to.getCaptchaImage();
                      },
                      child: Obx(() => UserService.to.captchaImage.value == null
                          ? const SizedBox()
                          : Image.memory(
                              base64.decode(
                                  UserService.to.captchaImage.value!.img),
                              width: 100,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox();
                              },
                            )),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: () async { 
                    if (UserService.to.loginLoading.value) {
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      // 登录或注册逻辑
                      if (status == LoginDialogStatus.login) {
                        // 登录逻辑
                        handleLogin(context);
                      } else if (status == LoginDialogStatus.register) {
                        // 注册逻辑
                        handleRegister();
                      } else {
                        await handleActiveMember();
                      }

                     
                    }
                  },
                  text: title,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (status == LoginDialogStatus.login ||
                            status == LoginDialogStatus.register)
                        ? TextButton(
                            onPressed: () async {
                              await UserService.to.getCaptchaImage();
                              status = status == LoginDialogStatus.login
                                  ? LoginDialogStatus.register
                                  : LoginDialogStatus.login;

                              resetForm();
                              setState(() {});
                            },
                            child: Text(status == LoginDialogStatus.login
                                ? '没有账号？注册'
                                : '已有账号？登录'),
                          )
                        : const SizedBox(),
                    TextButton(
                      onPressed: () async {
                        await UserService.to.getCaptchaImage();
                        status = LoginDialogStatus.active == status
                            ? LoginDialogStatus.login
                            : LoginDialogStatus.active;
                        resetForm();

                        setState(() {});
                      },
                      child: Text(
                          status == LoginDialogStatus.active ? '登录账号' : '激活账号'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleActiveMember() async {
    ActiveMemberParams activeMemberParams =
        ActiveMemberParams(
      email: _emailController.text.trim(),
      code: _captchaController.text.trim(),
      uuid: UserService.to.captchaImage.value?.uuid ?? '',
      activeCode: _activeCodeController.text.trim(),
    );
    bool isActive = await UserService.to
        .activeMember(activeMemberParams);
    if (isActive) {
      status = LoginDialogStatus.login;
    }
    await UserService.to.getCaptchaImage();
    status = LoginDialogStatus.login;
    resetForm();
    setState(() {
      
    });
  }

  Future<void> handleRegister() async {
    RegisterParams registerParams = RegisterParams(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        uuid: UserService.to.captchaImage.value?.uuid ?? '',
        code: _captchaController.text.trim(),
        confirmPassword: _passwordController.text.trim(),
        registerTerminal: registerTerminal);
    bool isRegister =
        await UserService.to.register(registerParams);
    if (isRegister) {
      status = LoginDialogStatus.active;
      _formKey.currentState?.reset();
      _captchaController.clear();
    }
    await UserService.to.getCaptchaImage();
    resetForm();
    setState(() {
      
    });
  }

  void handleLogin(BuildContext context)   {
     // 登录逻辑
    LoginParams loginParams = LoginParams(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        uuid: UserService.to.captchaImage.value?.uuid ?? '',
        code: _captchaController.text.trim());
      UserService.to.login(loginParams).then(( bool isLogin ){
          if (isLogin) {
                if(mounted){
                    Navigator.of(context).pop();
                }
              
                resetForm();
                 setState(() {});
              } else {
                  UserService.to.getCaptchaImage().then((value)=> setState(() {}),);
              }


    }); 
   
  }

  void resetForm() {
    _formKey.currentState?.reset();
    _passwordController.clear();
    _captchaController.clear();
    _activeCodeController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    _activeCodeController.dispose();
    super.dispose();
  }
}
