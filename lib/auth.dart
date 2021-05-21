import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Duration get loginTime => Duration(milliseconds: 2250);

  String? emailValidator(String? value) {
    if (value == null) {
      return 'Введите адрес электронной почты';
    }
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    bool flag = regExp.hasMatch(value);
    if (!flag) {
      return 'Неверный адрес электронной почты';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.length < 3) {
      return 'Слишком короткий пароль';
    }
    return null;
  }

  Future<String?>? _authUser(LoginData data) {
    return auth
        .signInWithEmailAndPassword(
      email: data.name,
      password: data.password,
    )
        .then(
      (value) => null,
      onError: (err) {
        if (err.code == 'user-not-found') {
          return "Пользователь не найден";
        }
        if (err.code == 'wrong-password') {
          return "Неверный пароль";
        }
        if (err.code == 'invalid-email') {
          return "Неправильный почтовый ящик";
        }
        return "Что-то пошло не так";
      },
    );
  }

  Future<String?>? _regUser(LoginData data) {
    return auth
        .createUserWithEmailAndPassword(
      email: data.name,
      password: data.password,
    )
        .then(
      (value) {
        User? user = auth.currentUser;
        if (user != null) {
          user.sendEmailVerification();
        }
      },
      onError: (err) {
        if (err.code == 'weak-password') {
          return "Слишком простой пароль";
        }
        if (err.code == 'email-already-in-use') {
          return "Данный почтовый ящик уже зарегистрирован";
        }

        if (err.code == 'invalid-email') {
          return "Неправильный почтовый ящик";
        }
        return "Что-то пошло не так";
      },
    );
  }

  Future<String?>? _recoverPassword(String email) {
    return auth.sendPasswordResetEmail(email: email).then(
      (value) => null,
      onError: (err) {
        if (err.code == 'user-not-found') {
          return "Пользователь не найден";
        }
        if (err.code == 'invalid-email') {
          return "Неправильный почтовый ящик";
        }
        return "Что-то пошло не так";
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kino Locations"),
      ),
      body: Center(
        child: FlutterLogin(
          onSubmitAnimationCompleted: () {
            Navigator.pop(context);
          },
          title: 'Вход и регистрация',
          onLogin: _authUser,
          onSignup: _regUser,
          onRecoverPassword: _recoverPassword,
          theme: LoginTheme(
            primaryColor: Colors.cyan,
            accentColor: Colors.deepPurple,
            buttonTheme: LoginButtonTheme(
              backgroundColor: Colors.deepPurple,
              splashColor: Colors.cyan,
              highlightColor: Colors.deepPurple,
            ),
          ),
          messages: LoginMessages(
            passwordHint: 'Введите пароль',
            confirmPasswordHint: 'Подтвердите пароль',
            forgotPasswordButton: 'Забыли пароль?',
            loginButton: 'ВОЙТИ',
            signupButton: 'ЗАРЕГИСТРИРОВАТЬСЯ',
            recoverPasswordButton: 'ВОССТАНОВИТЬ ПАРОЛЬ',
            recoverPasswordIntro: 'Восстановление пароля',
            recoverPasswordDescription:
                'Мы отправим вам ссылку для сброса пароля',
            goBackButton: 'НАЗАД',
            confirmPasswordError: 'Пароли не совпадают',
          ),
          emailValidator: emailValidator,
          passwordValidator: passwordValidator,
        ),
      ),
    );
  }
}
