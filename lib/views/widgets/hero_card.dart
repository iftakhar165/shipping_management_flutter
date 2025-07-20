import 'package:flutter/material.dart';

class HeroCard extends StatelessWidget {
  final String tag;
  final Widget child;
  final BorderRadius? borderRadius;

  const HeroCard({
    super.key,
    required this.tag,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

class HeroButton extends StatelessWidget {
  final String tag;
  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;

  const HeroButton({
    super.key,
    required this.tag,
    required this.child,
    this.onPressed,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: child,
        ),
      ),
    );
  }
}

class HeroIcon extends StatelessWidget {
  final String tag;
  final IconData icon;
  final Color? color;
  final double? size;

  const HeroIcon({
    super.key,
    required this.tag,
    required this.icon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }
}

class HeroText extends StatelessWidget {
  final String tag;
  final String text;
  final TextStyle? style;

  const HeroText({
    super.key,
    required this.tag,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: Text(
          text,
          style: style,
        ),
      ),
    );
  }
}

class HeroImage extends StatelessWidget {
  final String tag;
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const HeroImage({
    super.key,
    required this.tag,
    required this.image,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image(
            image: image,
            width: width,
            height: height,
            fit: fit,
          ),
        ),
      ),
    );
  }
}

class HeroContainer extends StatelessWidget {
  final String tag;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;

  const HeroContainer({
    super.key,
    required this.tag,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}

class CustomHeroTransition extends StatelessWidget {
  final String tag;
  final Widget child;
  final Widget Function(BuildContext, Animation<double>, Widget?) builder;

  const CustomHeroTransition({
    super.key,
    required this.tag,
    required this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => builder(context, animation, child),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}