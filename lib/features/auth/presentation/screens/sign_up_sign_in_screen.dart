import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/features/auth/data/models/sign_in_request_model.dart';
import 'package:frontend/features/auth/data/models/sign_up_request_model.dart';
import 'package:frontend/features/auth/presentation/widgets/draggable_form_sheet.dart';
import 'package:frontend/features/users/data/models/user_model.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _mailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Se inicializan los controladores de los campos de texto del formulario
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _mailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneNumberController.dispose();
    _mailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordObscured = !_isPasswordObscured);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured);
  }

  Future<void> _performSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Se recogen los datos del formulario
      final name = _nameController.text;
      final surname = _surnameController.text;
      final phone = _phoneNumberController.text;
      final mail = _mailController.text;
      final password = _passwordController.text;

      final int phonePrefix = 34;
      final int? phoneNumber = int.tryParse(phone);

      if (phoneNumber == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid phone number'), behavior: SnackBarBehavior.floating));
        setState(() => _isLoading = false);
        return;
      }

      final signUpRequest = SignUpRequestModel(
        name: name,
        surname: surname,
        phoneNumber: phoneNumber,
        phonePrefix: phonePrefix,
        mail: mail,
        password: password,
      );

      // Se obtiene el repositorio de autenticación a partir de la información proporcionada por el provider
      final authUseCases = context.read<AuthUseCases?>();
      if (authUseCases == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Initializing services, please wait...'), behavior: SnackBarBehavior.floating),
        );

        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }

        return;
      }

      // Se llama al caso de uso para realizar el registro
      final result = await authUseCases.signUp(signUpRequest);

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message), behavior: SnackBarBehavior.floating));
        },
        (authResponse) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sign up successful for  ${authResponse.user.name}! Token: ${authResponse.accessToken.substring(0, 10)}...',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );

          if (authResponse.user.role == Role.admin) {
            // TODO: Change to admin home screen
            Navigator.of(context).pushNamedAndRemoveUntil(AppConstants.clientHomeRoute, (route) => false);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(AppConstants.clientHomeRoute, (route) => false);
          }
        },
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SignUpSignInScreen(
      title: 'Hello, let’s get started!',
      subtitle: 'What’s your game?',
      formContent: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name*', border: OutlineInputBorder()),
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Surname', border: OutlineInputBorder()),
                autocorrect: false,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone number*',
                  prefixIcon: InkWell(
                    onTap: () {}, // TODO: Lógica para seleccionar prefijo
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_drop_down_rounded, color: colorScheme.outline),
                          CountryFlag.fromCountryCode(
                            'ES',
                            width: 24.0,
                            height: 18.0,
                            shape: const RoundedRectangle(2.0),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+ 34',
                            style: TextStyle(color: colorScheme.outline, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                autocorrect: false,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(labelText: 'Mail*', border: OutlineInputBorder()),
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mail';
                  }
                  final emailRegex = RegExp(r"^((?!\.)[\w\-_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$");
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password*',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                autocorrect: false,
                enableSuggestions: false,
                obscureText: _isPasswordObscured,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm password*',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
                autocorrect: false,
                enableSuggestions: false,
                obscureText: _isConfirmPasswordObscured,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
      isSignUp: true,
      onPrimaryAction: _performSignUp,
      isLoading: _isLoading,
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _mailController;
  late TextEditingController _passwordController;

  bool _isPasswordObscured = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Se inicializan los controladores de los campos de texto del formulario
    _mailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordObscured = !_isPasswordObscured);
  }

  Future<void> _performSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Se recogen los datos del formulario
      final mail = _mailController.text;
      final password = _passwordController.text;

      final signInRequest = SignInRequestModel(mail: mail, password: password);

      // Se obtiene el repositorio de autenticación a partir de la información proporcionada por el provider
      final authUseCases = context.read<AuthUseCases?>();
      if (authUseCases == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Initializing services, please wait...'), behavior: SnackBarBehavior.floating),
        );

        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }

        return;
      }

      // Se llama al caso de uso para realizar el inicio de sesión
      final result = await authUseCases.signIn(signInRequest);

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message), behavior: SnackBarBehavior.floating));
        },
        (authResponse) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sign in successful for ${authResponse.user.name}! Token: ${authResponse.accessToken.substring(0, 10)}...',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );

          if (authResponse.user.role == Role.admin) {
            // TODO: Change to admin home screen
            Navigator.of(context).pushNamedAndRemoveUntil(AppConstants.clientHomeRoute, (route) => false);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(AppConstants.clientHomeRoute, (route) => false);
          }
        },
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SignUpSignInScreen(
      title: 'Welcome back!',
      subtitle: 'What are we playing today?',
      formContent: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(labelText: 'Mail*', border: OutlineInputBorder()),
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mail';
                  }
                  final emailRegex = RegExp(r"^((?!\.)[\w\-_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$");
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password*',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                autocorrect: false,
                enableSuggestions: false,
                obscureText: _isPasswordObscured,
                textInputAction: TextInputAction.next,
                // Cambiado a .next si hay más campos o .done si es el último
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  // Podrías añadir más validaciones si es necesario, como la longitud mínima
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
      isSignUp: false,
      onPrimaryAction: _performSignIn,
      isLoading: _isLoading,
    );
  }
}

class _SignUpSignInScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> formContent;
  final bool isSignUp;
  final VoidCallback? onPrimaryAction; // Callback para la acción principal
  final bool isLoading;

  const _SignUpSignInScreen({
    required this.title,
    required this.subtitle,
    required this.formContent,
    required this.isSignUp,
    this.onPrimaryAction,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final Brightness statusBarIconBrightness =
        ThemeData.estimateBrightnessForColor(colorScheme.primary) == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: statusBarIconBrightness,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.displayMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(subtitle, style: textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: isSignUp
                    ? DraggableFormSheet(
                        formContent: formContent,
                        buttonLabel: 'Sign up',
                        bottomMessage: 'Already have an account?',
                        bottomButtonLabel: 'Sign in',
                        showDragHandle: true,
                      )
                    : DraggableFormSheet(
                        formContent: formContent,
                        buttonLabel: 'Sign in',
                        bottomMessage: 'Don\'t have an account?',
                        bottomButtonLabel: 'Sign up',
                        showDragHandle: false,
                        initialChildSize: 0.46,
                        minChildSize: 0.46,
                        maxSheetHeightProportionCap: 0.46,
                      ),
              ),
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: isLoading ? null : onPrimaryAction,
                      style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      child: isLoading
                          ? SizedBox(width: 24.0, height: 24.0, child: CircularProgressIndicator())
                          : Text(isSignUp ? 'Sign up' : 'Sign in'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSignUp ? 'Already have an account?' : 'Don\'t have an account?',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (isSignUp) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(AppConstants.signInRoute, (route) => false);
                                  } else {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(AppConstants.signUpRoute, (route) => false);
                                  }
                                },
                          child: Text(
                            isSignUp ? 'Sign in' : 'Sign up',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
