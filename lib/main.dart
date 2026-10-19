import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(auth: FirebaseAuth.instance));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF246B5A);

    return MaterialApp(
      title: 'VidCollab Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandColor,
          surface: const Color(0xFFF7F9F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: brandColor, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: auth == null ? const LoginPage() : AuthenticationGate(auth: auth!),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    final auth = widget.auth ?? FirebaseAuth.instance;
    setState(() => _isSubmitting = true);
    try {
      await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'invalid-email' => 'Enter a valid email address.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' => 'The email or password is incorrect.',
        'too-many-requests' =>
          'Too many attempts. Please wait and try again later.',
        'network-request-failed' =>
          'Could not connect. Check your internet connection and try again.',
        'operation-not-allowed' =>
          'Email and password sign-in is not enabled in Firebase.',
        _ => 'Could not sign in. Please try again.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on Exception catch (error) {
      debugPrint('Sign-in failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign in. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _requestPasswordReset() {
    if (!_emailFieldKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset is not configured yet.')),
    );
  }

  void _signUp() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SignupPage(auth: widget.auth)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.video_camera_back_rounded,
                            size: 44,
                            color: Color(0xFF246B5A),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome to VidCollab',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18332C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to your admin account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF687872),
                            ),
                          ),
                          const SizedBox(height: 36),
                          const Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF18332C),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            key: _emailFieldKey,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              hintText: 'Enter Email',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Enter your email';
                              if (!email.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submitLogin(),
                            decoration: const InputDecoration(
                              hintText: 'Enter Password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitLogin,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : _requestPasswordReset,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF246B5A),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Request reset password'),
                          ),
                          TextButton(
                            onPressed: _isSubmitting ? null : _signUp,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF246B5A),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, this.auth, this.firestore});

  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class AuthenticationGate extends StatelessWidget {
  const AuthenticationGate({super.key, required this.auth});

  final FirebaseAuth auth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Could not verify your sign-in status.')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data == null
            ? LoginPage(auth: auth)
            : AuthenticatedPage(auth: auth);
      },
    );
  }
}

class AuthenticatedPage extends StatelessWidget {
  const AuthenticatedPage({super.key, required this.auth});

  final FirebaseAuth auth;

  Future<void> _signOut(BuildContext context) async {
    try {
      await auth.signOut();
    } on FirebaseAuthException catch (error) {
      debugPrint('Sign-out failed (${error.code}): ${error.message}');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Please try again.')),
      );
    } on Exception catch (error) {
      debugPrint('Sign-out failed: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.video_camera_back_rounded,
                    size: 44,
                    color: Color(0xFF246B5A),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to VidCollab',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18332C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Signed in as ${auth.currentUser?.email ?? 'your account'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF687872),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _signOut(context),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    final auth = widget.auth ?? FirebaseAuth.instance;
    final email = _emailController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      final currentUser = auth.currentUser;
      final user =
          currentUser != null &&
              currentUser.email?.toLowerCase() == email.toLowerCase()
          ? currentUser
          : (await auth.createUserWithEmailAndPassword(
              email: email,
              password: _passwordController.text,
            )).user;
      if (user == null) {
        throw StateError('Firebase did not return the newly created user.');
      }

      await (widget.firestore ?? FirebaseFirestore.instance)
          .collection('user')
          .doc(user.uid)
          .set({
            'email': email,
            'mobile': '',
            'name': email,
            'userType': 'admin',
            'userid': user.uid,
          });
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'email-already-in-use' => 'An account already exists for this email.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' => 'Choose a stronger password.',
        'operation-not-allowed' =>
          'Email and password sign-up is not enabled in Firebase.',
        'network-request-failed' =>
          'Could not connect. Check your internet connection and try again.',
        'too-many-requests' =>
          'Too many attempts. Please wait and try again later.',
        _ => 'Could not create your account. Please try again.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (error) {
      debugPrint(
        'Saving Firestore profile failed (${error.code}): ${error.message}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created, but saving the profile failed. Check your connection and Firestore permissions, then retry.',
          ),
        ),
      );
    } on Exception catch (error) {
      debugPrint('Account or profile creation failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not complete signup. Please check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.video_camera_back_rounded,
                            size: 44,
                            color: Color(0xFF246B5A),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome to VidCollab',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18332C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your admin account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF687872),
                            ),
                          ),
                          const SizedBox(height: 36),
                          const Text(
                            'Sign up',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF18332C),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newUsername],
                            decoration: const InputDecoration(
                              hintText: 'Enter Email',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Enter your email';
                              if (!email.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onFieldSubmitted: (_) => _createAccount(),
                            decoration: const InputDecoration(
                              hintText: 'Enter Password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _createAccount,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Create account'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF246B5A),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Back to Login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
