import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/social_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepositoryImpl();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        setState(() {
          _errorMessage = 'Debes aceptar los términos y condiciones';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authRepository.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim().isEmpty 
              ? null 
              : _nameController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Navegar directamente a Home después del registro exitoso
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
          });
        }
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.signInWithGoogle();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con logo
                _buildHeader(),
                const SizedBox(height: 40),
                // Formulario
                _buildForm(),
                const SizedBox(height: 20),
                // Link de login
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo pequeño
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.2),
          ),
          child: const Icon(
            Icons.edit,
            size: 30,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Crear Cuenta',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Únete a aprendIA y mejora tu escritura',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de nombre
        CustomTextField(
          controller: _nameController,
          label: 'Nombre completo',
          hint: 'Tu nombre',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 20),
        // Campo de email
        CustomTextField(
          controller: _emailController,
          label: 'Correo electrónico',
          hint: 'tu@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu correo electrónico';
            }
            if (!value.contains('@')) {
              return 'Por favor ingresa un correo válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Campo de contraseña
        CustomTextField(
          controller: _passwordController,
          label: 'Contraseña',
          hint: 'Mínimo 8 caracteres',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.outline,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu contraseña';
            }
            if (value.length < AppConstants.minPasswordLength) {
              return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Campo de confirmar contraseña
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          hint: 'Repite tu contraseña',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.outline,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor confirma tu contraseña';
            }
            if (value != _passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Checkbox de términos
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _acceptTerms = !_acceptTerms;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Acepto los términos y condiciones',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Mensaje de error
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.onErrorContainer,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        // Botón de registro
        GradientButton(
          text: 'Registrarse',
          onPressed: _isLoading ? null : _handleRegister,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 20),
        // Divider
        _buildDivider(),
        const SizedBox(height: 20),
        // Botón de Google
        SocialButton(
          text: 'Registrarse con Google',
          icon: 'G',
          onPressed: _isLoading ? null : _handleGoogleRegister,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.outlineVariant,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'o',
            style: TextStyle(
              color: AppColors.outline,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.outlineVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿Ya tienes cuenta? ',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Inicia sesión',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
