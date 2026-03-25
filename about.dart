import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND IMAGE (THAY Ở ĐÂY) =====
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://static.vecteezy.com/system/resources/thumbnails/044/150/747/small_2x/abstract-luxury-gradient-blue-background-free-photo.jpg', // đổi link background tại đây
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== AVATAR (THAY Ở ĐÂY) =====
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                      'https://tse4.mm.bing.net/th/id/OIP.kAwEKrum70CcF9RCwwfnXAHaHa?rs=1&pid=ImgDetMain&o=7&rm=3g', // đổi avatar chính tại đây
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ===== NAME =====
                  const Text(
                    'Nhóm 20',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Chuyên Đề 2',
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  // ===== USER CARD =====
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        // ===== Avatar (THAY Ở ĐÂY) =====
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            'https://scontent.fhan3-1.fna.fbcdn.net/v/t39.30808-6/480541186_614238281468318_2875431063727586185_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=53a332&_nc_eui2=AeEzjxefnEKymeWI9ZcOg24jE-lp0nk0LT8T6WnSeTQtP2WfwMsfHLg5jNmwOjkKrd9MIlOyPaVhakskyLsoAB_i&_nc_ohc=PaqFAC_rY4oQ7kNvwG47vTG&_nc_oc=AdoU1ib35paI_uE-SlYS1r3B9AnQ8GDYDsexaO0uZ_5fqQBhRn7TkT3o55Vh2Yhf9h9QdvWXjH1NLEb5-nkLTlQ_&_nc_zt=23&_nc_ht=scontent.fhan3-1.fna&_nc_gid=ZVq2ZyMfmPc0pqDpRV10KA&_nc_ss=7a32e&oh=00_AfwVZEyFIX_4aFiDiMJnU2iBZZ0rzpshyO2tYO0-hT-sGA&oe=69C989E0',
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đặng Đình Tuấn',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '20222298',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        // ===== Avatar =====
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            'https://scontent.fhan3-5.fna.fbcdn.net/v/t39.30808-6/617879300_1353911806748888_5977280357688839849_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=1d70fc&_nc_eui2=AeGwlWKb0-sJyBARPV8RFd2KJk2L8SA1d-EmTYvxIDV34SDbsTW1Ty5_ddvSIPe3Dl-3taE4nufr_pexH2GHcwAL&_nc_ohc=14pdtrpYb1cQ7kNvwEknS9e&_nc_oc=Adq3xZp6nbJkhsB8NDv4Pg7ZBHusYLtg4Jt2-rOQGbHcRWzcg5RIc3h7ygYHYVRCqULhcoqOf8jNoiU7Tae9umb2&_nc_zt=23&_nc_ht=scontent.fhan3-5.fna&_nc_gid=9vloD2alAKzGcRdUuCoreA&_nc_ss=7a32e&oh=00_AfzEJFhGbwI1na5jCZ0_GT_b52Oe5dmoTVmP8bmB7PvaqQ&oe=69C99D6F',
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nguyễn Văn Nhật', // đổi tên tại đây
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '20222177', // mô tả
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
