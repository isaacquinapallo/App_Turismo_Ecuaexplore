import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'detalle_lugar.dart';
import 'services/auth_service.dart';
import 'services/image_service.dart';
import 'services/location_service.dart';
import 'login_page.dart';

class TurismoPage extends StatefulWidget {
  const TurismoPage({super.key});

  @override
  State<TurismoPage> createState() => _TurismoPageState();
}

class _TurismoPageState extends State<TurismoPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String descripcion = '';
  int valor = 0;
  String imagenUrl = '';
  bool _showForm =
      false; // Variable para controlar la visibilidad del formulario

  final _supabase = Supabase.instance.client;

  // Nuevas variables para las funcionalidades
  List<XFile> _selectedImages = [];
  String? _currentLocationLink;
  bool _isPublisher = false;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService.getUserProfile();
    final isPublisher = await AuthService.isPublisher();
    // Verificar si el widget está montado antes de llamar a setState
    if (!mounted) return;
    // Debug: imprimir información
    print('Debug - Usuario actual: ${AuthService.currentUser?.email}');
    print('Debug - Perfil: $profile');
    print('Debug - Es publicador: $isPublisher');

    setState(() {
      _userProfile = profile;
      _isPublisher = isPublisher;
    });
  }

  Future<void> _agregarLugar() async {
    // Validación extra de seguridad
    if (!_isPublisher) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Debes registrarte como publicador para agregar lugares.',
            ),
          ),
        );
      }
      return;
    }

    if (_formKey.currentState!.validate() && valor > 0) {
      _formKey.currentState!.save();

      try {
        // Subir imágenes al bucket si hay seleccionadas
        List<String> imageUrls = [];
        if (_selectedImages.isNotEmpty) {
          imageUrls = await ImageService.uploadMultipleImages(
            _selectedImages,
            'lugares-images',
          );
        }

        // Preparar datos para insertar
        final dataToInsert = {
          'lugar': nombre,
          'descripcion': descripcion,
          'valor': valor,
          'imagenUrl': imagenUrl.isNotEmpty ? imagenUrl : null,
          'imagenesUrl': imageUrls.isNotEmpty ? imageUrls : null,
          'ubicacionUrl': _currentLocationLink,
          'publicadoPor': AuthService.currentUser?.id,
        };

        await _supabase.from('turismo_lugares').insert(dataToInsert);

        _formKey.currentState!.reset();
        setState(() {
          valor = 0;
          _showForm = false;
          _selectedImages = [];
          _currentLocationLink = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lugar agregado exitosamente')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar lugar: $error')),
          );
        }
      }
    }
  }

  // Método para seleccionar imágenes
  Future<void> _selectImages() async {
    final images = await ImageService.showImageOptions(context);
    if (images != null) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  // Método para obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    try {
      final locationLink = await LocationService.getCurrentLocationLink();
      if (locationLink != null) {
        setState(() {
          _currentLocationLink = locationLink;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ubicación obtenida exitosamente')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo obtener la ubicación')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    }
  }

  // Método para cerrar sesión
  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calificación',
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 92, 92, 92),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  valor = index + 1;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.star,
                  size: 35,
                  color: index < valor
                      ? Colors.amber
                      : const Color.fromARGB(255, 252, 239, 156),
                ),
              ),
            );
          }),
        ),
        if (valor == 0)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Seleccione una calificación',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildFormOverlay() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Tamaño inicial del 70% de la pantalla
      minChildSize: 0.5, // Tamaño mínimo del 50%
      maxChildSize: 0.9, // Tamaño máximo del 90%
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de arrastre
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Barra superior con título y botón cerrar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agregar lugar turístico',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showForm = false;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campos del formulario
                    Column(
                      children: [
                        // Campo lugar (arriba)
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Lugar',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese un nombre' : null,
                          onSaved: (value) => nombre = value!,
                        ),
                        const SizedBox(height: 12),

                        // Campo URL imagen
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'URL de imagen',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese la URL' : null,
                          onSaved: (value) => imagenUrl = value!,
                        ),
                        const SizedBox(height: 12),

                        // Campo descripción
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          maxLines: 2,
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese una descripción' : null,
                          onSaved: (value) => descripcion = value!,
                        ),
                        const SizedBox(height: 16),

                        // Calificación con estrellas
                        _buildStarRating(),
                        const SizedBox(height: 16),

                        // Sección de imágenes
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Imágenes ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _selectImages,
                                      icon: const Icon(
                                        Icons.add_photo_alternate,
                                      ),
                                      label: const Text('Agregar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isPublisher
                                            ? const Color(0xFF4CAF50)
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_selectedImages.isNotEmpty) ...[
                                  Text(
                                    '${_selectedImages.length} imagen(es) seleccionada(s)',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _selectedImages.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: kIsWeb
                                                ? Image.network(
                                                    _selectedImages[index].path,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(
                                                      _selectedImages[index]
                                                          .path,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ] else
                                  const Text(
                                    'Opcional: Hasta 5 imágenes',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sección de ubicación
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Ubicación',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _getCurrentLocation,
                                      icon: const Icon(Icons.location_on),
                                      label: const Text('Obtener'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isPublisher
                                            ? const Color(0xFF4CAF50)
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_currentLocationLink != null)
                                  Text(
                                    'Ubicación obtenida ✓',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  )
                                else
                                  const Text(
                                    'Opcional: Toca para obtener ubicación actual',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón agregar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: valor > 0 ? _agregarLugar : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPublisher
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Agregar lugar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        // Espacio adicional para el teclado
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom > 0
                              ? 200
                              : 50,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Lugares turísticos'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () async {
              await _loadUserProfile();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Rol: ${_userProfile?['rol'] ?? 'sin rol'} | Es publicador: $_isPublisher',
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
          ),

          // ✅ Mostrar botón solo si no es publicador
          if (_userProfile == null || _userProfile?['rol'] != 'publicador')
            IconButton(
              onPressed: () {
                // 🔥 Simplemente redirige al LoginPage sin lógica adicional
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(
                      mensajeInicial:
                          'Debes iniciar sesión o registrarte como publicador',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
            ),

          if (_userProfile != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userProfile!['nombre'] ?? 'Usuario',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _userProfile!['rol'] ?? 'visitante',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),

      body: Stack(
        children: [
          // Lista de lugares
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase
                .from('turismo_lugares')
                .stream(primaryKey: ['id'])
                .order('lugar'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 80, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar datos',
                        style: TextStyle(fontSize: 18, color: Colors.red[700]),
                      ),
                      Text(
                        '${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final lugares = snapshot.data ?? [];
              if (lugares.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.place, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay lugares aún',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        'Agrega tu primer lugar turístico',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: lugares.length,
                itemBuilder: (context, index) {
                  final data = lugares[index];

                  // Convertir valor a int de forma segura
                  int rating = 0;
                  if (data.containsKey('valor') && data['valor'] != null) {
                    if (data['valor'] is String) {
                      rating = int.tryParse(data['valor']) ?? 0;
                    } else if (data['valor'] is int) {
                      rating = data['valor'];
                    }
                  }

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              (data['imagenesUrl'] != null &&
                                  data['imagenesUrl'].isNotEmpty)
                              ? Builder(
                                  builder: (context) {
                                    final pageController = PageController(
                                      viewportFraction: 0.9,
                                    );
                                    final List<String> imgList = [];

                                    if (data['imagenUrl'] != null &&
                                        data['imagenUrl'].isNotEmpty) {
                                      imgList.add(data['imagenUrl']);
                                    }

                                    if (data['imagenesUrl'] != null &&
                                        data['imagenesUrl'].isNotEmpty) {
                                      imgList.addAll(
                                        List<String>.from(data['imagenesUrl']),
                                      );
                                    }

                                    return Column(
                                      children: [
                                        Expanded(
                                          child: PageView.builder(
                                            controller: pageController,
                                            itemCount: imgList.length,
                                            itemBuilder: (context, pageIndex) {
                                              final imgUrl = imgList[pageIndex];
                                              return Image.network(
                                                imgUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                      );
                                                    },
                                              );
                                            },
                                          ),
                                        ),
                                        SmoothPageIndicator(
                                          controller: pageController,
                                          count: imgList.length,
                                          effect: WormEffect(
                                            dotHeight: 6,
                                            dotWidth: 6,
                                            activeDotColor: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : (data['imagenUrl'] != null &&
                                    data['imagenUrl'].isNotEmpty)
                              ? Image.network(
                                  data['imagenUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.place,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                        ),
                      ),

                      title: Text(
                        data['lugar'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            data['descripcion'] ?? 'Sin descripción',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      Icons.star,
                                      size: 16,
                                      color: starIndex < rating
                                          ? Colors.amber
                                          : Colors.grey[300],
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '($rating)',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleLugarPage(data: data),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),

          // Overlay del formulario
          if (_showForm) _buildFormOverlay(),
        ],
      ),

      // Botón flotante (debug: siempre visible temporalmente)
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showForm
            ? null
            : FloatingActionButton.extended(
                key: const ValueKey('add_button'),
                onPressed: _isPublisher
                    ? () {
                        setState(() {
                          _showForm = true;
                        });
                      }
                    : () {
                        final currentUser = AuthService.currentUser;
                        if (currentUser == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(
                                mensajeInicial:
                                    'Debes iniciar sesión para agregar lugares',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Debes ser publicador para agregar lugares. Rol actual: ${_userProfile?['rol'] ?? 'sin rol'}',
                              ),
                            ),
                          );
                        }
                      },
                backgroundColor: _isPublisher
                    ? const Color(0xFF4CAF50)
                    : Colors.grey,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  _isPublisher ? 'Agregar' : 'Registrar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
