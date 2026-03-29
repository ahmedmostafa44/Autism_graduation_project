import 'package:flutter/material.dart';
import 'package:autism_app/core/theme/app_theme.dart';

class GalaxyTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final bool isDark;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const GalaxyTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.isDark,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<GalaxyTextField> createState() => _GalaxyTextFieldState();
}

class _GalaxyTextFieldState extends State<GalaxyTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(
        color: GalaxyColors.textPrimary(widget.isDark),
        fontFamily: 'Nunito',
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon,
            color: GalaxyColors.textHint(widget.isDark), size: 20),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: GalaxyColors.textHint(widget.isDark),
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}

class GalaxyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final List<Color> gradient;

  const GalaxyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.gradient = const [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: loading
                ? [Colors.grey.shade600, Colors.grey.shade700]
                : gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: loading
              ? null
              : [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                  ),
                ),
        ),
      ),
    );
  }
}
