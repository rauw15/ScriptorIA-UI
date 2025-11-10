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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _authRepository = AuthRepositoryImpl();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  String? _errorMessage;
  
  // Valores para los dropdowns
  String? _selectedEntorno;
  String? _selectedNivelEducativo;
  
  // Opciones para los dropdowns
  static const List<String> _entornos = [
    'casa',
    'primaria',
    'secundaria',
    'preescolar',
    'preparatoria',
    'universidad',
    'centro_rehabilitacion',
  ];
  
  static const List<String> _nivelesEducativos = [
    'ninguno',
    'analfabeta',
    'educacion_inicial',
    'preescolar',
    'primaria',
    'secundaria',
    'bachillerato_general',
    'bachillerato_tecnico',
    'bachillerato_profesional',
    'licenciatura',
    'especialidad',
    'maestria',
    'doctorado',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
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

      if (_selectedEntorno == null) {
        setState(() {
          _errorMessage = 'Por favor selecciona un entorno';
        });
        return;
      }

      if (_selectedNivelEducativo == null) {
        setState(() {
          _errorMessage = 'Por favor selecciona un nivel educativo';
        });
        return;
      }

      final age = int.tryParse(_ageController.text.trim());
      if (age == null || age < 1 || age > 120) {
        setState(() {
          _errorMessage = 'Por favor ingresa una edad válida';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authRepository.register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          age: age,
          entorno: _selectedEntorno!,
          nivelEducativo: _selectedNivelEducativo!,
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
        // Campo de username
        CustomTextField(
          controller: _usernameController,
          label: 'Nombre de usuario',
          hint: 'Nombre de usuario',
          icon: Icons.person_outline,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un nombre de usuario';
            }
            if (value.contains(' ')) {
              return 'El nombre de usuario no puede contener espacios';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Campo de email
        CustomTextField(
          controller: _emailController,
          label: 'Correo electrónico',
          hint: 'Correo electrónico',
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
          hint: 'Contraseña (Mínimo 8 caracteres)',
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
          hint: 'Confirmar contraseña',
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
        // Campo de edad
        CustomTextField(
          controller: _ageController,
          label: 'Edad',
          hint: 'Edad',
          icon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu edad';
            }
            final age = int.tryParse(value);
            if (age == null || age < 1 || age > 120) {
              return 'Por favor ingresa una edad válida';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Dropdown de entorno
        _buildDropdown(
          label: 'Entorno',
          value: _selectedEntorno,
          items: _entornos,
          onChanged: (value) {
            setState(() {
              _selectedEntorno = value;
            });
          },
          icon: Icons.location_on_outlined,
          hint: 'Selecciona tu entorno',
        ),
        const SizedBox(height: 20),
        // Dropdown de nivel educativo
        _buildDropdown(
          label: 'Nivel educativo',
          value: _selectedNivelEducativo,
          items: _nivelesEducativos,
          onChanged: (value) {
            setState(() {
              _selectedNivelEducativo = value;
            });
          },
          icon: Icons.school_outlined,
          hint: 'Selecciona tu nivel educativo',
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required String hint,
  }) {
    // Función para convertir el valor a texto legible
    String _formatText(String text) {
      return text
          .split('_')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                icon,
                color: AppColors.outline,
                size: 20,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(_formatText(item)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor selecciona una opción';
            }
            return null;
          },
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
