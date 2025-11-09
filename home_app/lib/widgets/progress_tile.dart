
class _ProgressTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ProgressTile({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}