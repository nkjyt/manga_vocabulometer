import 'dart:ffi';

import 'package:flutter/material.dart';

enum AlertCategory {
  email_error,
  password_error,
  existed_user,
}

class AppUtils {
  buildAlertDialog(BuildContext context, String errorMessage) {
    print(errorMessage);
    /* switch (errorMessage) {
      case "PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null)":
        return buildAlreadyDialog(context);
      case "PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)":
        return buildBadFormatDialog(context);
      case "PlatformException(ERROR_USER_NOT_FOUND, There is no user record corresponding to this identifier. The user may have been deleted., null)":
        return buildUserNotFound(context);
      case "PlatformException(ERROR_WRONG_PASSWORD, The password is invalid or the user does not have a password., null)":
        return buildPasswordDialog(context);
      case "PlatformException(error, Given String is empty or null, null)":
        return buildNotInputDialog(context);
      case "Invalid Password":
        return buildInvalidPasswordDialog(context);
      default:
        return null;
    } */
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("ERROR"),
            content: Text(errorMessage),
          );
        });
  }

  buildAlreadyDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Regester error"),
            content:
                Text(" The email address is already in use by another account"),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  buildBadFormatDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Bad Formatted"),
            content: Text("The email address is badly formatted"),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  buildUserNotFound(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("User not found"),
            content: Text(
                "There is no user record corresponding to this identifier. The user may have been deleted"),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  buildPasswordDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Invalid Password"),
            content: Text(
                "The password is invalid or the user does not have a password."),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  buildNotInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Input is empty"),
            content: Text("Input email and password"),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  buildInvalidPasswordDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Invalid Password"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  buildNotOpenedDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Invalid test"),
            content: Text("This test is invalid yet"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  buildConfirmationDialog(BuildContext context, String title, String content) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  textFontSize(double fontSize) {
    return TextStyle(fontSize: fontSize);
  }
}
