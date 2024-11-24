import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HeaderWidget extends StatelessWidget {
  final void Function()? action;
  final String actionText;
  final String summaryText;
  final String titleText;
  final String backgroundAssetName;

  const HeaderWidget({
    this.titleText = '<title>',
    this.summaryText = '<summary>',
    this.actionText = '<action>',
    this.action,
    this.backgroundAssetName = 'assets/images/chalet.png',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;

    final summaryStyle = styles.bodyMedium!.copyWith(color: colors.onPrimary);
    final linkStyle = styles.bodyMedium!
        .copyWith(color: colors.primary, fontWeight: FontWeight.bold);

    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Image.asset(
            backgroundAssetName,
            fit: BoxFit.cover,
            color: const Color(0xB2293240),
            colorBlendMode: BlendMode.srcOver,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 112),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  style: styles.displayLarge!.copyWith(color: colors.onPrimary),
                  textAlign: TextAlign.center,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16)),
                ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(width: 768),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: summaryText),
                        if (action != null)
                          TextSpan(
                            text: actionText,
                            recognizer: TapGestureRecognizer()..onTap = action,
                            style: linkStyle,
                          ),
                      ],
                    ),
                    style: summaryStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                // if (action != null)
                //   const Padding(padding: EdgeInsets.symmetric(vertical: 16)),
                // if (action != null)
                //   TextButton(
                //     onPressed: action,
                //     child: Text(
                //       actionText,
                //       style: styles.bodyLarge!.copyWith(color: colors.primary),
                //       textAlign: TextAlign.center,
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
