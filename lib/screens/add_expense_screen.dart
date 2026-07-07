import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Alimentación';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Alimentación',
    'Transporte',
    'Salud',
    'Educación',
    'Entretenimiento',
    'Servicios',
    'Otros',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double amount = double.parse(
      _amountController.text.replaceAll(',', '.'),
    );

    final expense = Expense(
      amount: amount,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    await DatabaseHelper.instance.insertExpense(expense);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gasto registrado correctamente')),
    );

    Navigator.pop(context, true);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar gasto'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Nuevo gasto',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el monto del gasto';
                  }

                  final amount = double.tryParse(value.replaceAll(',', '.'));

                  if (amount == null) {
                    return 'Ingresa un monto válido';
                  }

                  if (amount <= 0) {
                    return 'El monto debe ser mayor que cero';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text('Fecha: ${_formatDate(_selectedDate)}'),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _saveExpense,
                icon: const Icon(Icons.save),
                label: const Text('Guardar gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
