import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retorna o usuário atual, null se não autenticado
  User? get currentUser => _auth.currentUser;

  // Retorna o userId do usuário atual ou lança exceção se não autenticado
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado");
    }
    return user.uid;
  }

  // Login com email e senha
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // sucesso
    } on FirebaseAuthException catch (_) {
       if(email == '' || password == ''){
         return "Preencha todos os campos";
      }
      return "Email ou senha incorretos";
    } catch (e) {
      return "Erro desconhecido ao tentar logar";
    }
  }

  // Registro com email e senha
  Future<String?> register(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Preencha todos os campos";
      }

      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; //sucesso

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "E-mail já em uso!";
      } else {
        return e.message; // Outras mensagens de erro do Firebase
      }
    } catch (e) {
      return "Erro desconhecido ao tentar registrar";
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
