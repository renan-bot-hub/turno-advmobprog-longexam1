import 'custom_font.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import 'package:flutter/material.dart';

void customDialog(BuildContext context, {required title, required content}) {
  AlertDialog alertDialog = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_DARK_PRIMARY,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Okay'),
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}

void customOptionDialog(
  BuildContext context, {
  required title,
  required content,
  required Function onYes,
}) {
  AlertDialog alertDialog = AlertDialog(
    title: CustomFont(text: title, fontSize: 30.sp, color: Colors.white),
    content: CustomFont(text: content, fontSize: 30.sp, color: Colors.white),
    actions: <Widget>[
      OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: CustomFont(text: 'No', fontSize: 30.sp, color: Colors.white),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onYes();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_DARK_PRIMARY,
          foregroundColor: Colors.white,
        ),
        child: CustomFont(text: 'Yes', fontSize: 30.sp, color: Colors.white),
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}

void customShowImageDialog(
  BuildContext context, {
  required String image,
  bool isNetwork = false,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Stack(
          children: [
            SizedBox(
              height: 300.h,
              child: Center(
                child: isNetwork
                    ? CachedNetworkImage(
                        imageUrl: image,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                          color: FB_DARK_PRIMARY,
                          value: downloadProgress.progress,
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, size: 100.sp, color: Colors.grey,),
                      )
                    : ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: double.infinity,
                        minHeight: ScreenUtil().setSp(250),
                        maxHeight: ScreenUtil().setSp(250)
                      ),
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                      ),
                    )
              ),
            ),

            Positioned(
              top: -8.h,
              right: -16.w,
              child: IconButton(
                icon: Icon(Icons.close, size: 24.sp),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
