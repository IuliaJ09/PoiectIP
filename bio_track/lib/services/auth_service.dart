import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<bool> loginWithCNP(String cnp, String parola) async {
    final response = await supabase
        .from('Pacient')
        .select()
        .eq('cnp', cnp)
        .eq('parola', parola)
        .maybeSingle();

    return response != null;
  }
}
