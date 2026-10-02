import 'package:flutter/material.dart';

bool isAssetImage(String path) => path.startsWith('assets/');

ImageProvider avatarImage(String path) =>
    isAssetImage(path) ? AssetImage(path) : NetworkImage(path);
