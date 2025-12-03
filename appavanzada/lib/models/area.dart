class Area {
  final int? id;
  final String name;
  final int tipo; // 0 dentro, 1 fuera, 2 copiar
  final String? imageSeed;

  Area({this.id, required this.name, required this.tipo, this.imageSeed});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'tipo': tipo, 'imageSeed': imageSeed};
  }

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: map['id'] as int?,
      name: map['name'] as String,
      tipo: map['tipo'] as int,
      imageSeed: map['imageSeed'] as String?,
    );
  }
   String imageUrlForArea(String name) {
    final n = name.toLowerCase();
    if (n.contains('comedor'))
      return 'https://planner5d.com/blog/content/images/2025/04/comedor.negro.moderno.jpg';
    if (n.contains('sala'))
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIMSPRKFfVsCtWkgx8mNgJvr4FVN6JIeZFJQ&s';
    if (n.contains('cocina'))
      return 'https://st.hzcdn.com/simgs/65419c56074741bf_14-8315/home-design.jpg';
    if (n.contains('dormitorio'))
      return 'https://content.elmueble.com/medio/2025/04/01/dormitorio-con-cabecero-de-obra-00560141_2bbe7015_00560141_250401120859_2000x1333.webp';
    if (n.contains('jard'))
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRA5C8z0O7wLEKqRGhE3D5LbWb07hL4Dwxj4A&s';
    if (n.contains('garaj'))
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTUTCBzg8sMF-2cTFNzb6U9lj2DkCyzxYkpQ&s';
    if(n.contains('baño'))
      return 'https://inspirame.corona.co/wp-content/uploads/2023/08/productos-lanzamiento-Corona-3-1024x614.jpg';
    if(n.contains('terraza'))
      return 'https://st.hzcdn.com/simgs/54d10a2e05cfcd6d_14-7361/home-design.jpg';
    if(n.contains('patio'))
      return 'https://st.hzcdn.com/simgs/dec122f30f1444cb_4-2239/contemporaneo-patio.jpg';
    return 'https://images.homify.com/v1440015283/p/photo/image/832767/JLF_6309.jpg';
  }
}
