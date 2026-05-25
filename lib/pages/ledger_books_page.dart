import 'package:flutter/material.dart';

import '../models/ledger_book.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_card.dart';
import '../widgets/flow_page.dart';
import '../widgets/section_title.dart';

sealed class LedgerBooksResult {
  const LedgerBooksResult();
}

class SelectLedgerBookResult extends LedgerBooksResult {
  const SelectLedgerBookResult(this.bookId);

  final String bookId;
}

class AddLedgerBookResult extends LedgerBooksResult {
  const AddLedgerBookResult(this.name);

  final String name;
}

class DeleteLedgerBookResult extends LedgerBooksResult {
  const DeleteLedgerBookResult(this.bookId);

  final String bookId;
}

class LedgerBooksPage extends StatelessWidget {
  const LedgerBooksPage({
    super.key,
    required this.books,
    required this.selectedBookId,
  });

  final List<LedgerBook> books;
  final String selectedBookId;

  @override
  Widget build(BuildContext context) {
    return FlowPage(
      title: '账本',
      subtitle: '新建、切换和删除账本',
      child: ListView(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('当前账本'),
                const SizedBox(height: 8),
                Text('首页顶部会显示当前选中的账本。', style: AppText.muted(context)),
                const SizedBox(height: 12),
                for (final book in books)
                  BookRow(
                    book: book,
                    selected: book.id == selectedBookId,
                    canDelete: books.length > 1,
                    onSelect: () => Navigator.of(
                      context,
                    ).pop(SelectLedgerBookResult(book.id)),
                    onDelete: () => _confirmDelete(context, book),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _showAddBookDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('新建账本'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBookDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('新建账本'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '例如 工作后的账本'),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty && context.mounted) {
      Navigator.of(context).pop(AddLedgerBookResult(name.trim()));
    }
  }

  Future<void> _confirmDelete(BuildContext context, LedgerBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('删除${book.name}？'),
        content: const Text('这个账本下的当前内存流水也会一起移除。接入本地数据库后会改成可恢复备份。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(DeleteLedgerBookResult(book.id));
    }
  }
}

class BookRow extends StatelessWidget {
  const BookRow({
    super.key,
    required this.book,
    required this.selected,
    required this.canDelete,
    required this.onSelect,
    required this.onDelete,
  });

  final LedgerBook book;
  final bool selected;
  final bool canDelete;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onSelect,
      leading: Icon(
        selected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: selected ? AppColors.primary : AppColors.muted,
      ),
      title: Text(book.name),
      subtitle: Text(book.description),
      trailing: IconButton(
        onPressed: canDelete ? onDelete : null,
        icon: const Icon(Icons.delete_outline),
        tooltip: '删除账本',
      ),
    );
  }
}
