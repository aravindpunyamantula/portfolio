export interface HeroContent {
  greeting: string;
  name: string;
  nameShort: string;
  roles: string[];
  tagline: string;
  availability: string;
  showAvailability: boolean;
  footerTagline: string;
  currentlyBuilding?: string;
}

export interface LinksContent {
  github: string;
  linkedin: string;
  instagram: string;
  email: string;
  resume: string;
}

export interface ProjectStoryLayer {
  id: "interface" | "logic" | "data";
  title: string;
  description: string;
  technologies: string[];
}
export interface ProjectStoryContent {
  audience?: string;
  contribution?: string;
  outcome?: string;
  layers: ProjectStoryLayer[];
}
export interface ProjectModel {
  title: string;
  description: string;
  imageUrl?: string;
  liveUrl?: string;
  githubUrl?: string;
  order?: number;
  tags?: string[];
  story?: ProjectStoryContent;
}

export interface SkillCategory {
  title: string;
  skills: string[];
  color: string;
}

export interface CertificateModel {
  title: string;
  organisation: string;
  date: string;
  link?: string;
  skills: string[];
  imageUrl?: string;
  order?: number;
}

export interface ReviewModel {
  name: string;
  role: string;
  company: string;
  message: string;
  avatarUrl?: string;
  rating?: number;
}

export interface SectionHeaderContent {
  eyebrow: string;
  title: string;
  subtitle: string;
}

export interface PortfolioContent {
  hero: HeroContent;
  links: LinksContent;
  projects: ProjectModel[];
  certificates: CertificateModel[];
  skillCategories: SkillCategory[];
  reviews: ReviewModel[];
  sections: Record<string, SectionHeaderContent>;
}

export interface GithubStats {
  repos: number;
  commits: number;
}
