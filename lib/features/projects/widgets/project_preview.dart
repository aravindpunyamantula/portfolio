import 'package:flutter/material.dart';
import 'package:portfolio/data/models/project_model.dart';
import 'package:portfolio/features/projects/widgets/github_readme_preview.dart';
import 'package:portfolio/features/projects/widgets/live_webiste_preview.dart';

class ProjectPreview extends StatelessWidget {
  final ProjectModel project;
  const ProjectPreview({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    switch (project.previewType) {
      case ProjectPreviewType.live:
        return _buildLivePreview(context);
      case ProjectPreviewType.github:
        return _buildGithubPreview(context);
      case ProjectPreviewType.image:
        return _buildImagePreview(context);
    }
  }

  Widget _buildLivePreview(BuildContext context) {
    return LiveWebistePreview(url: project.projectLink ?? "");
  }

  Widget _buildGithubPreview(BuildContext context) {
    return GithubReadmePreview(repoUrl: project.githubLink ?? "");
  }

  Widget _buildImagePreview(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        project.projectImageUrl ?? "",
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
