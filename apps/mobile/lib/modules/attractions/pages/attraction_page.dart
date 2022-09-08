import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itourism_mobile/modules/maps/components/maps_component.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../controllers/attractions_controller.dart';
import '../models/attraction_model.dart';

class AttractionPage extends StatelessWidget {
  final Attraction attraction;
  late final String attractionId;

  final AttractionsController attractionController =
      Modular.get<AttractionsController>();

  AttractionPage({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () async {
        await attractionController.fetchAttraction(attractionId);
      },
      child: Observer(
        builder: (context) {
          if (attractionController.loading &&
              attractionController.attractions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (attractionController.attractions.isEmpty) {
            return const Center(
              child: Text('Local não encontrado'),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.width,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        itemCount: attraction.gallery.length,
                        itemBuilder: (context, index) {
                          final image = attraction.gallery[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                image,
                                fit: BoxFit.cover,
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: AnimatedSmoothIndicator(
                                      activeIndex: index,
                                      count: attraction.gallery.length,
                                      effect: const WormEffect(
                                        dotHeight: 8,
                                        dotWidth: 8,
                                        activeDotColor: Colors.white,
                                        dotColor: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: ListTile(
                          title: Text(
                            attraction.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              letterSpacing: 1.4,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                attraction.address,
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Divider(
                        color: Colors.white60,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: const Text(
                          'Descrição',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            letterSpacing: 1.2,
                          ),
                        ),
                        subtitle: Text(
                          attraction.description,
                          textAlign: TextAlign.justify,
                          maxLines: 4,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const ListTile(
                          title: Text(
                            'Localização',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: MapComponent(
                            onTap: () {
                              Modular.to.pushNamed(
                                '/maps/?title=${attraction.name}',
                                arguments: CameraPosition(
                                  target: LatLng(
                                    attraction.latitude,
                                    attraction.longitude,
                                  ),
                                  zoom: 4,
                                ),
                              );
                            },
                            cameraPosition:
                                const CameraPosition(target: LatLng(0, 0)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}
