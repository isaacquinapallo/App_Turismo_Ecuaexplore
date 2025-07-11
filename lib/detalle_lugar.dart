//detalle_lugar.dart
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';

class DetalleLugarPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetalleLugarPage({super.key, required this.data});

  @override
  State<DetalleLugarPage> createState() => _DetalleLugarPageState();
}

class _DetalleLugarPageState extends State<DetalleLugarPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  final _supabase = Supabase.instance.client;
  final _resenaController = TextEditingController();
  bool _isPublisher = false;
  List<Map<String, dynamic>> _resenas = [];
  bool _isLoadingResenas = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadResenas();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _resenaController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final isPublisher = await AuthService.isPublisher();
    setState(() {
      _isPublisher = isPublisher;
    });
  }

  Future<void> _loadResenas() async {
    setState(() {
      _isLoadingResenas = true;
    });

    try {
      final resenasPrincipales = await _supabase
          .from('turismo_resenas')
          .select(
            '*, perfil:turismo_perfiles!turismo_resenas_usuario_id_fkey(nombre)',
          )
          .eq('lugar_id', widget.data['id'])
          .isFilter('resena_padre', null)
          .order('created_at', ascending: false);

      final respuestas = await _supabase
          .from('turismo_resenas')
          .select(
            '*, perfil:turismo_perfiles!turismo_resenas_usuario_id_fkey(nombre)',
          )
          .eq('lugar_id', widget.data['id'])
          .not('resena_padre', 'is', null);

      // 3️⃣ Agrupar respuestas por resena_padre
      final respuestasPorPadre = <int, List<Map<String, dynamic>>>{};
      for (final resp in respuestas) {
        final padreId = resp['resena_padre'];
        if (padreId != null) {
          respuestasPorPadre.putIfAbsent(padreId, () => []).add(resp);
        }
      }

      // 4️⃣ Agregar las respuestas a cada reseña principal
      for (final resena in resenasPrincipales) {
        final resenaId = resena['id'];
        resena['respuestas'] = respuestasPorPadre[resenaId] ?? [];
      }

      setState(() {
        _resenas = List<Map<String, dynamic>>.from(resenasPrincipales);
        _isLoadingResenas = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingResenas = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando reseñas: $e')));
      }
    }
  }

  Future<void> _agregarResena({int? resenaPadre}) async {
    if (_resenaController.text.trim().isEmpty) return;

    try {
      await _supabase.from('turismo_resenas').insert({
        'lugar_id': widget.data['id'],
        'usuario_id': AuthService.currentUser!.id,
        'contenido': _resenaController.text.trim(),
        'resena_padre': resenaPadre,
      });

      _resenaController.clear();
      await _loadResenas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resenaPadre == null ? 'Resena agregada' : 'Respuesta agregada',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.data['lugar'] ?? 'Lugar turistico')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes
            _buildImageCarousel(),
            const SizedBox(height: 20),

            // Título y puntuación
            _buildTitleAndRating(),
            const SizedBox(height: 20),

            // Descripción
            _buildDescription(),
            const SizedBox(height: 20),

            // Botón de ubicación
            _buildLocationButton(),
            const SizedBox(height: 30),

            // Sección de reseñas
            _buildReviewsSection(),

            // Botón para regresar
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Regresar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final List<String> images = [];

    if (widget.data['imagenUrl'] != null &&
        widget.data['imagenUrl'].isNotEmpty) {
      images.add(widget.data['imagenUrl']);
    }

    if (widget.data['imagenesUrl'] != null &&
        widget.data['imagenesUrl'].isNotEmpty) {
      images.addAll(List<String>.from(widget.data['imagenesUrl']));
    }

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.image_not_supported,
          size: 100,
          color: Colors.grey,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _pageController,
          count: images.length,
          effect: WormEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.data['lugar'] ?? 'Sin nombre',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                widget.data.containsKey('valor') && widget.data['valor'] != null
                    ? widget.data['valor'].toString()
                    : 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripcion',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          widget.data['descripcion'] ?? 'Sin descripcion',
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    if (widget.data['ubicacionUrl'] == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidad de ubicacion pendiente'),
            ),
          );
        },
        icon: const Icon(Icons.location_on),
        label: const Text('Ver ubicacion en Google Maps'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resenas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Campo para agregar reseña (solo para publicadores)
        if (_isPublisher) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _resenaController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu resena...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _agregarResena(),
                      child: const Text('Agregar Resena'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Lista de reseñas
        if (_isLoadingResenas)
          const Center(child: CircularProgressIndicator())
        else if (_resenas.isEmpty)
          const Center(
            child: Text(
              'No hay resenas aun',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _resenas.length,
            itemBuilder: (context, index) {
              return _buildReviewItem(_resenas[index]);
            },
          ),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> resena) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  resena['perfil']?['nombre'] ?? 'Usuario anonimo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatDate(resena['created_at']),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(resena['contenido'] ?? ''),

            // Botón para responder (solo para publicadores)
            if (_isPublisher) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _showReplyDialog(resena['id']),
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Responder'),
              ),
            ],

            // Mostrar respuestas si las hay
            if (resena['respuestas'] != null &&
                resena['respuestas'].isNotEmpty) ...[
              const SizedBox(height: 12),
              ...resena['respuestas'].map<Widget>((respuesta) {
                return Container(
                  margin: const EdgeInsets.only(left: 24, top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            respuesta['perfil']?['nombre'] ?? 'Usuario anonimo',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(respuesta['created_at']),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        respuesta['contenido'] ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(int resenaId) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder resena'),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe tu respuesta...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _agregarResena(resenaPadre: resenaId);
            },
            child: const Text('Responder'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
