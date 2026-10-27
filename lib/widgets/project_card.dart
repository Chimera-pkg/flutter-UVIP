import 'package:flutter/material.dart';
import 'package:uvip/models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final dynamic onMorePressed;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onDelete,
    this.onMorePressed,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      try {
        final parts = dateStr.split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            final day = parts[2].padLeft(2, '0');
            final month = parts[1].padLeft(2, '0');
            return '$day/$month/${parts[0]}';
          } else if (parts[2].length == 4) {
            final day = parts[0].padLeft(2, '0');
            final month = parts[1].padLeft(2, '0');
            return '$day/$month/${parts[2]}';
          }
        }
      } catch (_) {}
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileCount = project.photoCount + project.videoCount;
    final formattedDate = _formatDate(project.createdAt);
    final subtitleText = formattedDate.isNotEmpty
        ? '$fileCount files ; $formattedDate'
        : '$fileCount files';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Row(
            children: [
              // Thumbnail image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: _buildThumbnail(),
                ),
              ),
              const SizedBox(width: 14),

              // Title and media count / date
              // Sesuai permintaan: status TIDAK ditampilkan di halaman project list
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitleText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // More options button (3 horizontal dots)
              Builder(
                builder: (buttonContext) {
                  return IconButton(
                    icon: const Icon(Icons.more_horiz),
                    color: const Color(0xFF334155),
                    iconSize: 22,
                    splashRadius: 20,
                    onPressed: () {
                      if (onMorePressed != null) {
                        if (onMorePressed is void Function(BuildContext)) {
                          onMorePressed(buttonContext);
                        } else if (onMorePressed is VoidCallback) {
                          onMorePressed();
                        } else {
                          try {
                            (onMorePressed as dynamic)(buttonContext);
                          } catch (_) {
                            (onMorePressed as dynamic)();
                          }
                        }
                      } else if (onDelete != null) {
                        onDelete!();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = project.thumbnailUrl;
    if (url != null && url.isNotEmpty) {
      String fullUrl = url.replaceAll('\\', '/');
      if (!fullUrl.startsWith('http')) {
        const baseUrl = 'http://80.241.214.39';
        fullUrl =
            '$baseUrl/${fullUrl.startsWith('/') ? fullUrl.substring(1) : fullUrl}';
      }
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackThumbnail(),
      );
    }
    return _fallbackThumbnail();
  }

  Widget _fallbackThumbnail() {
    return Image.network(
      'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=150&auto=format&fit=crop&q=80',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: Icon(Icons.streetview, color: Color(0xFF64748B), size: 26),
        ),
      ),
    );
  }
}
