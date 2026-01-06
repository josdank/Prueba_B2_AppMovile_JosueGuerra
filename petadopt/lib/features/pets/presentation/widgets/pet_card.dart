import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  final Widget? trailing;

  const PetCard({super.key, required this.pet, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: pet.photoUrl.isEmpty
                ? Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.pets))
                : CachedNetworkImage(imageUrl: pet.photoUrl, fit: BoxFit.cover),
          ),
        ),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${pet.species} • ${pet.breed} • ${pet.age} años'),
        trailing: trailing,
      ),
    );
  }
}
