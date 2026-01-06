import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../providers.dart';

class PetFormPage extends ConsumerStatefulWidget {
  final String? petId;
  const PetFormPage({super.key, this.petId});

  @override
  ConsumerState<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends ConsumerState<PetFormPage> {
  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String status = 'available';

  // Fotos: 1..5
  final List<String> imagePaths = [];
  int primaryIndex = 0;

  // Salud (se guarda en description como notas para no romper tu BD actual)
  bool vaccinated = false;
  bool dewormed = false;
  bool sterilized = false;
  bool microchip = false;
  bool specialCare = false;
  final _healthNotesCtrl = TextEditingController();

  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _healthNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    // pickMultiImage está soportado en Android
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      for (final p in picked) {
        if (imagePaths.length >= 5) break;
        imagePaths.add(p.path);
      }
      if (primaryIndex >= imagePaths.length) primaryIndex = 0;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      imagePaths.removeAt(index);
      if (imagePaths.isEmpty) {
        primaryIndex = 0;
      } else if (primaryIndex == index) {
        primaryIndex = 0;
      } else if (primaryIndex > index) {
        primaryIndex -= 1;
      }
    });
  }

  void _setPrimary(int index) {
    setState(() => primaryIndex = index);
  }

  void _addSuggestion(String text) {
    final cur = _descCtrl.text.trim();
    final add = (cur.isEmpty ? '' : '$cur ') + text;
    _descCtrl.text = add;
    _descCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _descCtrl.text.length));
    setState(() {});
  }

  String _buildFullDescription() {
    // Guardamos salud como bloque al final (sin romper tu estructura actual)
    final health = <String>[];
    if (vaccinated) health.add('Vacunado/a');
    if (dewormed) health.add('Desparasitado/a');
    if (sterilized) health.add('Esterilizado/a');
    if (microchip) health.add('Microchip');
    if (specialCare) health.add('Cuidados especiales');
    final notes = _healthNotesCtrl.text.trim();

    final base = _descCtrl.text.trim();

    final healthBlock = (health.isEmpty && notes.isEmpty)
        ? ''
        : '\n\n---\nSalud: ${health.isEmpty ? 'N/D' : health.join(', ')}'
            '${notes.isEmpty ? '' : '\nNotas: $notes'}';

    return (base + healthBlock).trim();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final species = _speciesCtrl.text.trim();
    final breed = _breedCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    final description = _buildFullDescription();

    if (name.isEmpty || species.isEmpty || breed.isEmpty || age <= 0 || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }
    if (imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos 1 foto')),
      );
      return;
    }

    await ref.read(petsControllerProvider.notifier).createOrUpdate(
          id: widget.petId,
          name: name,
          species: species,
          breed: breed,
          age: age,
          description: description,
          status: status,
          imagePaths: imagePaths,
          primaryIndex: primaryIndex,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(petsControllerProvider).isLoading;

    return AppScaffold(
      title: 'Nueva Mascota',
      trailing: IconButton(
        icon: const Icon(Icons.save),
        onPressed: saving ? null : _submit,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Completa todos los campos requeridos', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 14),

          // Fotos
          _Section(
            title: 'Fotos de la Mascota',
            subtitle: 'Mínimo 1 foto, máximo 5. La principal se usa en el catálogo.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (int i = 0; i < imagePaths.length; i++)
                      _PhotoTile(
                        path: imagePaths[i],
                        isPrimary: i == primaryIndex,
                        onPrimary: saving ? null : () => _setPrimary(i),
                        onRemove: saving ? null : () => _removePhoto(i),
                      ),
                    if (imagePaths.length < 5)
                      _AddPhotoTile(onTap: saving ? null : _addPhotos),
                  ],
                ),
                const SizedBox(height: 10),
                Text('${imagePaths.length}/5 fotos agregadas. Las fotos de buena calidad aumentan adopciones.',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Info básica
          _Section(
            title: 'Información Básica',
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(labelText: 'Nombre de la mascota', hintText: 'Ej: Luna, Rocky, Michi...'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _speciesCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(labelText: 'Especie (perro/gato)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _breedCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(labelText: 'Raza'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ageCtrl,
                  enabled: !saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Edad (años)'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(value: 'available', child: Text('Disponible')),
                    DropdownMenuItem(value: 'adopted', child: Text('Adoptado')),
                  ],
                  onChanged: saving ? null : (v) => setState(() => status = v ?? 'available'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Descripción + chips
          _Section(
            title: 'Descripción',
            subtitle: 'Cuéntanos sobre esta mascota',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _descCtrl,
                  enabled: !saving,
                  maxLength: 500,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Describe su personalidad, historia, comportamiento con niños y otras mascotas...',
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Sugerencias:', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SuggestChip(text: '+ Juguetón', onTap: () => _addSuggestion('Juguetón')),
                    _SuggestChip(text: '+ Tranquilo', onTap: () => _addSuggestion('Tranquilo')),
                    _SuggestChip(text: '+ Cariñoso', onTap: () => _addSuggestion('Cariñoso')),
                    _SuggestChip(text: '+ Ideal para niños', onTap: () => _addSuggestion('Ideal para niños')),
                    _SuggestChip(text: '+ Apto departamento', onTap: () => _addSuggestion('Apto departamento')),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Salud
          _Section(
            title: 'Estado de Salud',
            child: Column(
              children: [
                _HealthTile(
                  title: 'Vacunado/a',
                  subtitle: 'Tiene todas las vacunas al día',
                  value: vaccinated,
                  onChanged: saving ? null : (v) => setState(() => vaccinated = v),
                ),
                _HealthTile(
                  title: 'Desparasitado/a',
                  subtitle: 'Tratamiento antiparasitario completado',
                  value: dewormed,
                  onChanged: saving ? null : (v) => setState(() => dewormed = v),
                ),
                _HealthTile(
                  title: 'Esterilizado/a',
                  subtitle: 'Ha sido castrado/a o esterilizado/a',
                  value: sterilized,
                  onChanged: saving ? null : (v) => setState(() => sterilized = v),
                ),
                _HealthTile(
                  title: 'Microchip',
                  subtitle: 'Tiene microchip de identificación',
                  value: microchip,
                  onChanged: saving ? null : (v) => setState(() => microchip = v),
                ),
                _HealthTile(
                  title: 'Requiere cuidados especiales',
                  subtitle: 'Necesita medicación o atención particular',
                  value: specialCare,
                  onChanged: saving ? null : (v) => setState(() => specialCare = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _healthNotesCtrl,
                  enabled: !saving,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notas adicionales de salud (opcional)',
                    hintText: 'Alergias, medicamentos, condiciones crónicas...',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Botón inferior estilo mock
          FilledButton.icon(
            onPressed: saving ? null : _submit,
            icon: saving
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            label: Text(saving ? 'Publicando...' : 'Publicar Mascota'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _Section({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(fontSize: 12)),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 98,
        height: 98,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary, style: BorderStyle.solid, width: 1.2),
        ),
        child: const Center(child: Icon(Icons.add_a_photo)),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String path;
  final bool isPrimary;
  final VoidCallback? onPrimary;
  final VoidCallback? onRemove;

  const _PhotoTile({
    required this.path,
    required this.isPrimary,
    required this.onPrimary,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(File(path), width: 98, height: 98, fit: BoxFit.cover),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Color.fromARGB(255, 209, 99, 99)),
            ),
          ),
        ),
        Positioned(
          bottom: 6,
          left: 6,
          child: InkWell(
            onTap: onPrimary,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black.withOpacity(.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isPrimary ? 'PRINCIPAL' : 'Hacer principal',
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(text),
    );
  }
}

class _HealthTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _HealthTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Checkbox(value: value, onChanged: enabled ? (v) => onChanged!(v ?? false) : null),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12)),
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
