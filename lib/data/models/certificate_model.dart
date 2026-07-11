class CertificateModel {
  final String title;
  final String organisation;
  final String date;
  final String link;
  final List<String> skills;
  final String imageUrl;

  CertificateModel({
    required this.title,
    required this.organisation,
    required this.date,
    required this.link,
    required this.skills,
    required this.imageUrl,
  });
}

final sampleCertificates = [
  CertificateModel(
    title: "MongoDB Associate Developer",
    organisation: "MongoDB",
    date: "March 2026",
    link:
        "https://www.credly.com/badges/e452746d-b6d1-4acf-862b-1eb1eb264528/print",
    skills: ["MongoDB", "NOSQL"],
    imageUrl:
        "https://media.licdn.com/dms/image/v2/D5622AQEIXasoegQxog/feedshare-image-high-res/B56Z05ygcTKgAU-/0/1774791034974?e=1780531200&v=beta&t=B6pU9Is64TZ2QSDZdn-fP6OmlN-sDePEmmRyz6YuMtk",
  ),
  CertificateModel(
    title: "Github Foundations",
    organisation: "Microsoft",
    date: "March 2026",
    link:
        "https://learn.microsoft.com/api/credentials/share/en-gb/AravindKumar-3069/3ED3F9AEA1C13502?sharingId=5389773CB19015D",
    skills: ["Git", "Github"],
    imageUrl:
        "https://media.licdn.com/dms/image/v2/D5622AQHOqCij3ff5DA/feedshare-shrink_1280/B56Z05x01RJkAM-/0/1774790856265?e=1780531200&v=beta&t=G1T7V4OG76eFFgHqbXirxSuurpgNiRclgisouGV8xBs",
  ),

  CertificateModel(
    title:
        'Oracle Cloud Infrastructure 2025 Certified AI Foundations Associate',
    organisation: 'Oracle',
    date: 'November 2025',
    link:
        'https://catalog-education.oracle.com/ords/certview/sharebadge?id=6D540D14E0EAEB1CE165371859E721C5D79BA0FAFAE4CADCC467236AE2E061EF',
    skills: ["ML(BASIC)", "AI(BASIC)"],
    imageUrl:
        'https://brm-workforce.oracle.com/pdf/certview/images/OCI25AICFAV1.png',
  ),

  CertificateModel(
    title: 'Oracle Certified  Foundations Associate Database',
    organisation: 'Oracle',
    date: 'November 2025',
    link:
        'https://catalog-education.oracle.com/ords/certview/sharebadge?id=6D540D14E0EAEB1CE165371859E721C5D79BA0FAFAE4CADCC467236AE2E061EF',
    skills: ["SQL", "OracleDB"],
    imageUrl:
        'https://media.licdn.com/dms/image/v2/D5622AQGGQdeJ_-WBtw/feedshare-shrink_1280/B56Zm6wX31KMAw-/0/1759774868753?e=1780531200&v=beta&t=tu0g2I3llnaFrkmCJfCFWRrdbDfEMKdJ0QFugIxd99Q',
  ),
  CertificateModel(
    title: 'Python Essential 1',
    organisation: 'Cisco',
    date: 'November 2024',
    link:
        'https://www.credly.com/badges/8893586c-f9ba-4d73-bbce-446aac25e299/linked_in_profile',
    skills: ["Python"],
    imageUrl:
        'https://images.credly.com/size/340x340/images/68c0b94d-f6ac-40b1-a0e0-921439eb092e/image.png',
  ),
  CertificateModel(
    title: 'Java Programming',
    organisation: 'Oracle',
    date: 'October 2024',
    link: '',
    skills: ["Java"],
    imageUrl:
        'https://media.licdn.com/dms/image/v2/D562DAQHhtnJdkJPEgQ/profile-treasury-document-images_800/B56Zbd4eqoHgAk-/1/1747479294051?e=1779926400&v=beta&t=AWprzi1wnqDRTfU7Bprf46eXs8d3AamNOeCjY51QkAw',
  ),
];
