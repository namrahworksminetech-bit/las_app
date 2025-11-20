import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Ast {
  static const $Svg svg = $Svg();
  static const $Image img = $Image();
}

//For SVG
class $Svg {
  const $Svg();

  AssetsSvg get logo => const AssetsSvg('logo');
  AssetsSvg get feedback => const AssetsSvg('feedback');

  AssetsSvg get ic_bn_home => const AssetsSvg('ic_bn_home');
  AssetsSvg get ic_bn_home_fill => const AssetsSvg('ic_bn_home_fill');

  AssetsSvg get ic_bn_portfolio => const AssetsSvg('ic_bn_portfolio');
  AssetsSvg get ic_bn_portfolio_fill => const AssetsSvg('ic_bn_portfolio_fill');

  AssetsSvg get ic_bn_transaction => const AssetsSvg('ic_bn_transaction');
  AssetsSvg get ic_bn_transaction_fill => const AssetsSvg('ic_bn_transaction_fill');

  AssetsSvg get ic_bn_profile => const AssetsSvg('ic_bn_profile');
  AssetsSvg get ic_bn_profile_fill => const AssetsSvg('ic_bn_profile_fill');
  AssetsSvg get ic_add => const AssetsSvg('ic_add');
  AssetsSvg get ic_copy => const AssetsSvg('ic_copy');
  AssetsSvg get ic_next => const AssetsSvg('ic_next');
  AssetsSvg get ic_link => const AssetsSvg('ic_link');
  AssetsSvg get ic_logout => const AssetsSvg('ic_logout');
  AssetsSvg get ic_verify => const AssetsSvg('ic_verify');
  AssetsSvg get ic_back => const AssetsSvg('ic_back');
  AssetsSvg get ic_down => const AssetsSvg('ic_down');
  AssetsSvg get ve_logo => const AssetsSvg('ve_logo');
  AssetsSvg get ic_repay => const AssetsSvg('ic_repay');
}

//For Image
enum Extension { png, jpg, jpeg }

class $Image {
  const $Image();

  AssetsImage get img_profile => const AssetsImage('img_profile');

  AssetsImageProvider get dark_background2 => const AssetsImageProvider('w5');
}

class AssetsImage {
  final String name;
  final Extension extension;

  const AssetsImage(this.name, {this.extension = Extension.png});

  Image load({
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
  }) {
    return Image.asset(
      'assets/$name.${extension.name}',
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }
}

class AssetsImageProvider {
  final String name;
  final Extension extension;

  const AssetsImageProvider(this.name, {this.extension = Extension.png});

  ImageProvider load() {
    return AssetImage('assets/$name.${extension.name}');
  }
}

class AssetsSvg {
  final String name;

  const AssetsSvg(this.name);

  SvgPicture load({
    double? width,
    double? height,
    Color? color,
    BlendMode? blendMode,
    BoxFit fit = BoxFit.fill,
  }) {
    return SvgPicture.asset(
      'assets/$name.svg',
      width: width,
      height: height,
      colorFilter: color != null
          ? ColorFilter.mode(
              color,
              blendMode ?? BlendMode.srcIn,
            )
          : null,
      fit: fit,
    );
  }
}
