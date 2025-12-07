class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome';
    }
    
    if (value.trim().length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }

    // Verifica se tem pelo menos nome e sobrenome
    final parts = value.trim().split(' ');
    if (parts.length < 2) {
      return 'Informe nome completo';
    }

    return null;
  }

  static String? validateCpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o CPF';
    }

    // Remove formatação
    final cpf = value.replaceAll(RegExp(r'\D'), '');

    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Validação dos dígitos verificadores
    List<int> numbers = cpf.split('').map((e) => int.parse(e)).toList();

    // Calcula primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;

    if (numbers[9] != firstDigit) {
      return 'CPF inválido';
    }

    // Calcula segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;

    if (numbers[10] != secondDigit) {
      return 'CPF inválido';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o telefone';
    }

    // Remove formatação
    final phone = value.replaceAll(RegExp(r'\D'), '');

    if (phone.length < 10) {
      return 'Telefone incompleto';
    }

    if (phone.length > 11) {
      return 'Telefone inválido';
    }

    // Valida DDD
    final ddd = int.tryParse(phone.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) {
      return 'DDD inválido';
    }

    return null;
  }
}
