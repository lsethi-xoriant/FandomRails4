require "pg"
require "yaml"
require "json"
require "fileutils"

def main

  if ARGV.size != 1
    puts <<-EOF
      Usage: #{$0} <config.yml>
    EOF
    exit
  end

  start_time = Time.now
  puts "#{start_time} - Braun logs fix started"

  config = YAML.load_file(ARGV[0].to_s)
  conn = PG::Connection.open(config["production_db"])
  events_conn = PG::Connection.open(config["events_db"])

  conn.exec("SET search_path TO '#{config['tenant']}'") if config["tenant"]

  user_without_registration_log_ids = [251, 3565, 3028, 2409, 264, 5411, 4466, 2311, 599, 1789, 2769, 4321, 4059, 4875, 5161, 2148, 1060, 1478, 3367, 1229, 2150, 4650, 3911, 1726, 2206, 1487, 4057, 3823, 3924, 3142, 541, 2452, 3054, 2210, 1065, 252, 5080, 2300, 958, 325, 1999, 1333, 1783, 5561, 3510, 5329, 4910, 282, 4105, 1364, 2019, 5170, 4089, 629, 1606, 4355, 5506, 5409, 1264, 4145, 5504, 280, 1374, 1981, 2886, 2925, 2363, 1139, 1963, 1800, 4976, 2183, 3491, 4291, 4449, 2753, 3853, 923, 3082, 977, 4453, 1551, 5610, 3707, 570, 1049, 896, 429, 3029, 2480, 1806, 2153, 530, 653, 2506, 1089, 1475, 3034, 3249, 5141, 1978, 5240, 603, 2625, 5370, 3910, 5558, 803, 4347, 1091, 1018, 2856, 928, 4027, 4248, 2355, 987, 3135, 2262, 1432, 2562, 1213, 3173, 5378, 1564, 1301, 2561, 2621, 2105, 1322, 1762, 4241, 1588, 4274, 4788, 5121, 2445, 1040, 5460, 390, 1624, 4887, 4643, 1511, 3292, 2940, 1937, 1492, 4390, 1979, 2857, 3024, 811, 4090, 4672, 2593, 1438, 1770, 4043, 3557, 1313, 5617, 4307, 3726, 4378, 5325, 3437, 5675, 4266, 3423, 2404, 3136, 5599, 591, 3630, 521, 715, 5332, 1823, 4823, 1234, 1891, 2010, 4824, 4614, 3680, 5491, 4825, 488, 4596, 1654, 5441, 680, 2464, 1643, 4637, 1035, 4920, 4940, 5467, 1255, 1170, 1751, 3774, 1685, 4077, 4216, 2253, 3731, 619, 562, 1297, 1617, 975, 4908, 668, 4329, 1277, 4326, 1521, 229, 5052, 3442, 1016, 2269, 4240, 2892, 2909, 884, 2820, 3497, 3245, 2377, 1192, 1436, 1360, 5455, 4715, 4177, 2657, 4493, 592, 4629, 4278, 4710, 2663, 4889, 283, 3692, 2923, 548, 1195, 3389, 5290, 681, 2334, 647, 3674, 4255, 2956, 3141, 2342, 4866, 1728, 1676, 5369, 4364, 518, 4916, 1680, 1845, 2676, 4098, 2437, 2187, 1818, 4500, 5189, 2950, 4992, 4606, 1546, 1922, 2699, 883, 3159, 4630, 4651, 2427, 2032, 4118, 1502, 2666, 2229, 4228, 4339, 838, 3359, 4695, 1178, 2589, 3069, 3693, 4865, 882, 5042, 2534, 2851, 563, 4306, 479, 2213, 284, 4428, 5013, 239, 2698, 4652, 4778, 2133, 1919, 3019, 4401, 2722, 2871, 3696, 4664, 3149, 234, 841, 4995, 1451, 1150, 938, 1063, 5207, 444, 274, 5456, 1518, 5117, 4626, 851, 5076, 3503, 984, 3091, 2398, 596, 5338, 2140, 642, 5523, 1359, 433, 2584, 2967, 293, 1828, 3983, 2037, 1705, 2631, 4182, 3832, 475, 2388, 3110, 5683, 5, 2695, 593, 3921, 3980, 4785, 4158, 661, 4870, 5623, 5276, 1417, 979, 1766, 2507, 4252, 1834, 5592, 254, 625, 656, 4988, 1292, 3901, 5665, 1203, 5387, 2104, 2279, 4061, 2546, 5439, 1799, 2246, 5510, 2511, 5081, 5025, 1621, 1549, 1653, 5152, 3582, 3713, 3017, 2238, 2661, 1328, 1202, 4425, 3093, 492, 755, 1220, 1343, 4966, 4254, 2087, 5636, 1940, 3992, 5379, 4215, 1663, 5244, 5615, 2336, 3944, 646, 2549, 1781, 2149, 725, 2064, 707, 4847, 1572, 1138, 571, 1925, 2144, 4273, 2008, 622, 2576, 2854, 1908, 1603, 3554, 3444, 3981, 828, 4430, 4953, 454, 4798, 2036, 2675, 4167, 4597, 4394, 1612, 2934, 669, 4418, 5061, 2690, 4515, 1765, 5367, 4107, 708, 1737, 2947, 4333, 4398, 2885, 5101, 409, 2745, 5046, 1154, 986, 3011, 3841, 2314, 2160, 5341, 4135, 691, 3053, 3035, 389, 767, 641, 1844, 2916, 951, 269, 534, 2512, 835, 3396, 688, 2063, 3968, 3716, 3816, 5465, 1362, 1550, 3101, 4590, 2469, 3386, 1928, 2633, 2610, 955, 1325, 1686, 3390, 2895, 2930, 4971, 1973, 1132, 4688, 2298, 5225, 4951, 393, 1787, 2429, 778, 4007, 3248, 1197, 5354, 1921, 1472, 5478, 2684, 5458, 1254, 1700, 734, 1068, 2566, 4896, 5680, 1287, 1574, 2674, 4754, 4817, 4238, 4331, 501, 2379, 2948, 3098, 3288, 4552, 246, 1788, 267, 354, 5093, 1279, 1594, 4756, 4396, 5363, 4649, 2315, 4797, 4049, 4751, 5412, 2340, 2594, 3327, 3616, 2792, 1028, 4983, 1526, 2365, 5518, 1775, 3111, 5065, 323, 4792, 5287, 1397, 2171, 407, 2166, 275, 3537, 948, 2226, 371, 990, 677, 1, 666, 5394, 3870, 4611, 1352, 1144, 1797, 372, 3978, 1363, 3074, 3287, 912, 5423, 1950, 2861, 2046, 2435, 422, 3629, 4130, 3278, 4407, 3213, 3165, 905, 3006, 245, 4444, 3025, 5246, 259, 1266, 1015, 3998, 1710, 3055, 864, 291, 3827, 901, 3240, 2192, 3977, 5125, 3280, 4520, 2242, 1562, 2632, 4655, 1384, 5112, 2463, 2786, 4377, 5345, 4975, 1894, 1177, 2227, 5361, 3994, 4993, 4853, 989, 2042, 972, 1326, 3052, 490, 4014, 5289, 4949, 5110, 2921, 1497, 3797, 5573, 2735, 5079, 5200, 3272, 887, 3401, 2598, 1513, 3318, 3871, 3356, 4776, 1080, 2415, 2125, 2263, 3311, 4987, 4281, 5211, 5031, 4858, 3795, 756, 3001, 3995, 921, 253, 270, 2870, 2439, 3312, 2055, 2779, 339, 3937, 1048, 1253, 2308, 1348, 2156, 2515, 3189, 3586, 4679, 3895, 3230, 5658, 1864, 2228, 5437, 1578, 785, 1920, 3351, 5228, 1295, 774, 1335, 3254, 5427, 3810, 4943, 839, 5583, 4184, 5150, 526, 4748, 559, 1914, 1293, 1473, 4319, 4166, 812, 1768, 980, 3720, 2304, 504, 1749, 633, 1003, 1188, 4625, 5352, 3925, 5023, 4658, 2486, 686, 3463, 3589, 2376, 3948, 1847, 2652, 5679, 4297, 4985, 2554, 2059, 243, 672, 5280, 1736, 4409, 4997, 2092, 4270, 3262, 1715, 3892, 2620, 3157, 1858, 2119, 2778, 533, 1175, 2671, 1153, 1555, 3475, 4828, 727, 886, 781, 1527, 689, 2526, 2703, 473, 1723, 813, 4657, 3581, 5291, 2186, 970, 3436, 2096, 5479, 1285, 1632, 2747, 1747, 1201, 4264, 1734, 946, 2873, 1647, 4880, 2072, 2155, 4786, 3796, 1429, 1141, 4925, 2859, 4802, 5429, 4175, 1989, 1699, 4934, 3226, 5035, 3838, 695, 2078, 3594, 737, 3209, 5317, 5611, 4581, 5297, 5309, 5574, 610, 782, 287, 4819, 5432, 4174, 1630, 3955, 1056, 1672, 1156, 1137, 4353, 983, 3364, 3117, 4340, 4647, 3556, 2536, 2305, 4868, 1499, 1211, 1484, 2312, 5589, 1491, 954, 1561, 1930, 1790, 3171, 2626, 5454, 5128, 589, 913, 3072, 3517, 3120, 3340, 2585, 2027, 2322, 2045, 1798, 4739, 546, 3686, 736, 1006, 278, 2406, 875, 3103, 2884, 2762, 3782, 758, 4568, 1658, 2457, 3373, 5362, 2975, 1517, 5381, 4551, 3739, 456, 728, 4362, 1873, 1052, 2436, 256, 4876, 5139, 2714, 1755, 809, 1815, 1501, 881, 4836, 3532, 2395, 4854, 1270, 2764, 4894, 5576, 262, 1002, 2053, 4054, 5390, 3504, 4602, 585, 1684, 1862, 1942, 2385, 5355, 3678, 4084, 5158, 4899, 4506, 5148, 3365, 2682, 5621, 5169, 2844, 4205, 5484, 5528, 1310, 3425, 5063, 1767, 5550, 1730, 3476, 2280, 2984, 5094, 1983, 2935, 5263, 1115, 1327, 604, 1646, 842, 4855, 1282, 961, 2214, 3325, 2996, 4457, 4332, 2218, 5145, 5183, 2350, 5260, 2374, 3734, 5055, 2170, 1615, 2095, 5310, 1483, 3970, 3888, 724, 2744, 4656, 5322, 1055, 1406, 1652, 1745, 5314, 1392, 1248, 1169, 1291, 334, 3646, 1238, 2402, 552, 273, 3969, 3175, 2490, 1221, 4111, 3591, 3211, 2994, 2292, 387, 4763, 5493, 1641, 1560, 4574, 2644, 4998, 4930, 1977, 1237, 4322, 999, 904, 2128, 227, 1579, 1278, 4684, 5631, 5018, 5421, 3212, 2609, 3119, 4729, 2159, 2985, 5374, 2913, 2272, 3736, 4842, 4639, 1398, 1668, 857, 1205, 5613, 4771, 1743, 2718, 2912, 3397, 3188, 3361, 1172, 290, 793, 3947, 2638, 2222, 2689, 4344, 1256, 2697, 1149, 2239, 2749, 3030, 3265, 4327, 4744, 3727, 495, 4789, 1719, 3414, 5138, 618, 1593, 1307, 5533, 3583, 1094, 3134, 1970, 5279, 1086, 1931, 4717, 731, 3772, 597, 3987, 4031, 4262, 2175, 2595, 1515, 4354, 1988, 2152, 2190, 1305, 902, 5233, 634, 1189, 5513, 4051, 1760, 2001, 602, 2271, 1315, 5522, 1687, 3281, 1395, 4897, 5133, 3090, 1540, 527, 773, 783, 1503, 1608, 4967, 2788, 1456, 3916, 1208, 1991, 4588, 260, 5186, 3480, 3935, 3099, 3514, 2412, 231, 5642, 2341, 328, 3538, 2281, 1538, 4567, 5122, 263, 3368, 4921, 664, 4093, 1042, 1167, 1495, 4676, 3732, 5430, 5530, 4073, 4904, 1929, 5377, 5650, 5108, 1946, 2582, 852, 4841, 4604, 2203, 1092, 310, 2162, 3179, 4735, 1614, 1369, 3817, 836, 1490, 1746, 2602, 4721, 5609, 2082, 4046, 5060, 265, 996, 1162, 3570, 5293, 5405, 910, 2901, 1707, 4179, 238, 2543, 3307, 4736, 1936, 2185, 4682, 5440, 3387, 765, 1399, 2691, 1299, 2607, 2130, 733, 3274, 3515, 5252, 3104, 2972, 4426, 2897, 1980, 2193, 3824, 2248, 2220, 5428, 4469, 2555, 3964, 662, 2216, 1031, 3363, 255, 1033, 1019, 1875, 2474, 3116, 2132, 1377, 827, 640, 2005, 3247, 1899, 2748, 779, 288, 1997, 1375, 949, 505, 2158, 1469, 3760, 614, 848, 2705, 2108, 4432, 2891, 1251, 3470, 5482, 777, 4691, 5526, 898, 4194, 1554, 1014, 4784, 3536, 1263, 4140, 4702, 4585, 5092, 2575, 5184, 696, 1772, 3337, 4143, 3394, 1531, 1702, 1140, 5529, 4463, 3544, 2212, 4505, 3005, 1428, 1985, 919, 361, 1681, 2596, 1246, 1386, 2569, 261, 3123, 348, 4783, 868, 4202, 332, 4320, 2424, 3269, 1500, 3056, 2030, 569, 1901, 3220, 233, 1863, 2498, 2277, 3416, 2426, 4805, 4900, 500, 2017, 1152, 3679, 3481, 4337, 2770, 5570, 532, 1524, 5471, 976, 4413, 5235, 897, 1599, 1935, 499, 5056, 3362, 3176, 4533, 2223, 3749, 3375, 1011, 5450, 2007, 673, 2806, 3730, 4932, 3266, 4977, 679, 493, 1506, 775, 2202, 3106, 3382, 576, 5422, 3020, 3779, 258, 3084, 966, 2495, 5180, 2318, 2357, 3156, 5425, 3792, 1062, 1447, 1889, 2772, 1626, 2380, 1448, 2287, 1644, 2413, 4566, 1107, 4653, 1739, 5278, 2297, 2172, 2368, 2417, 5580, 244, 5475, 1657, 2040, 1236, 2113, 4366, 3614, 4058, 1078, 3369, 4955, 4923, 1157, 3043, 1882, 744, 2951, 985, 5407, 3930, 4690, 1402, 551, 2319, 2194, 4074, 2819, 3422, 3143, 5284, 5307, 2995, 732, 967, 2151, 3974, 4660, 1968, 3691, 3773, 299, 5238, 2805, 4827, 2405, 5271, 329, 5348, 2954, 3392, 2571, 5468, 439, 2294, 4393, 4257, 5477, 1568, 3806, 5395, 5320, 4644, 4895, 1110, 2011, 2818, 3160, 309, 3710, 4560, 3641, 5564, 4796, 5077, 2422, 5261, 2808, 5627, 5420, 1067, 1103, 447, 3567, 1814, 4564, 3737, 4429, 1962, 2264, 4018, 934, 249, 2205, 5677, 1216, 4689, 2532, 5149, 3092, 352, 2740, 4036, 735, 4762, 3550, 513, 586, 3702, 5107, 2358, 5607, 2236, 4047, 3314, 529, 2612, 4563, 5585, 2006, 3447, 4038, 1604, 2791, 3607, 1807, 1969, 4697, 3007, 4001, 248, 1025, 2099, 3186, 1481, 1507, 2483, 4619, 3059, 2736, 4800, 1467, 2926, 3620, 1619, 698, 5350, 5630, 2725, 2443, 242, 1290, 1380, 1349, 3780, 3077, 5330, 342, 854, 236, 1442, 1808, 294, 2963, 3625, 5129, 1666, 4913, 257, 4707, 4726, 3421, 4203, 2493, 4335, 5534, 3645, 4030, 5647, 650, 1166, 998, 1391, 754, 4947, 5181, 4713, 2331, 3347, 2141, 2905, 608, 4172, 2060, 4218, 3764, 4181, 5187, 572, 4954, 978, 1577, 2215, 2560, 2583, 1720, 760, 5103, 5037, 5340, 829, 1061, 1410, 3308, 2120, 5655, 1923, 2143, 4261, 1638, 1054, 2599, 4133, 4843, 4864, 3740, 2821, 4375, 1024, 1965, 2839, 510, 4328, 4492, 2825, 4878, 771, 2488, 4673, 5474, 3547, 522, 3, 3083, 4149, 1649, 3766, 4549, 2608, 859, 1318, 4412, 3264, 5074, 584, 1329, 1694, 4454, 4835, 3512, 878, 2097, 3494, 867, 4357, 5226, 4536, 1228, 3167, 2721, 1294, 926, 3405, 4446, 5353, 4263, 1302, 2906, 3811, 2477, 240, 4365, 5517, 5601, 538, 612, 5010, 3404, 1350, 2847, 5039, 276, 3535, 4029, 3647, 1083, 2285, 4495, 2813, 1283, 3358, 3949, 5067, 3319, 2328, 1662, 4593, 2642, 1741, 2261, 5249, 1171, 449, 1146, 899, 1108, 1665, 4519, 2505, 706, 2219, 3685, 5134, 2444, 4129, 3128, 4905, 5130, 489, 3086, 2293, 4634, 1757, 241, 816, 1079, 2741, 1740, 524, 5538, 2421, 4609, 995, 4292, 1416, 1569, 3700, 4494, 2942, 1488, 1280, 413, 5674, 2646, 3606, 2390, 480, 2169, 5554, 2650, 4928, 2165, 2061, 1958, 1458, 2329, 3598, 4692, 2458, 2438, 2497, 3724, 3048, 2028, 5172, 891, 3733, 4686, 1180, 5360, 1453, 1118, 4112, 2605, 4488, 723, 2978, 3825, 1372, 2823, 2668, 2843, 1611, 1131, 4330, 401, 281, 1274, 2521, 5259, 5414, 1553, 5335, 4173, 5664, 3479, 1029, 1575, 5415, 643, 3065, 4128, 1832, 2191, 1122, 1181, 3530, 3033, 2407, 1819, 2696, 232, 692, 739, 3545, 3777, 4675, 1934, 535, 1952, 2274, 2122, 5486, 2802, 4350, 2174, 266, 2102, 2069, 3619, 2408, 4636, 1721, 1595, 876, 5418, 1415, 2344, 1005, 4117, 5337, 1271, 514, 4677, 1995, 1426, 5157, 1859, 5269, 4538, 1130, 4296, 670, 2299, 940, 697, 1761, 5666, 2865, 4041, 5678, 2177, 5202, 5586, 4023, 710, 3456, 2929, 5221, 3172, 3219, 3818, 4620, 1623, 2303, 2665, 5569, 2845, 2085, 2282, 5053, 5671, 1176, 1423, 1032, 2482, 4231, 3790, 4025, 4727, 1441, 2545, 2278, 4243, 4670, 5231, 3372, 3210, 1648, 4044, 4510, 1688, 3250, 1683, 4791, 1634, 509, 3789, 2139, 713, 2893, 720, 5505, 4021, 247, 5105, 2434, 4770, 1155, 3621, 1992, 1618, 2320, 4627, 2513, 4151, 4373, 5085, 4164, 1544, 3451, 3315, 4850, 1039, 1113, 5339, 2629, 2849, 890, 3298, 5342, 3932, 237, 3636, 2904, 906, 3976, 1909, 4267, 1752, 3651, 1272, 2346, 1010, 3778, 2071, 5389, 1857, 4706, 2043, 1257, 4383, 3709, 3000, 2425, 598, 472, 4276, 2960, 1284, 911, 916, 3667, 3800, 1245, 4522, 2494, 2041, 3419, 1939, 4067, 2137, 772, 2352, 1918, 1534, 740, 1185, 4287, 285, 866, 3958, 5489, 497, 1351, 5652, 452, 2743, 5403, 2658, 3500, 700, 620, 1541, 2872, 1114, 486, 3154, 5304, 2702, 2147, 3484, 4079, 1273, 5469, 1496, 5515, 4037, 4890, 4100, 2662, 5083, 5089, 1573, 3723, 5388, 3303, 508, 1961, 3650, 1085, 2766, 1592, 4302, 4666, 5399, 1964, 3946, 1207, 4968, 2517, 408, 5673, 2751, 2782, 4683, 2516, 1598, 4226, 4470, 346, 3988, 2710, 1194, 1690, 5667, 3231, 2325, 5302, 1853, 2199, 4555, 3023, 1082, 4733]
  user_without_credit_log_ids = [2409, 264, 1101, 2311, 2627, 359, 1060, 1478, 2485, 2150, 1726, 2640, 2206, 1487, 2452, 2210, 1065, 537, 2300, 974, 325, 914, 1389, 2266, 1275, 478, 458, 2038, 629, 2572, 1264, 1528, 280, 1139, 1000, 2542, 2230, 1963, 1800, 1966, 2339, 712, 1910, 515, 1427, 2717, 429, 1242, 2153, 530, 653, 2677, 2362, 1017, 1978, 603, 2625, 1091, 1018, 1233, 2384, 2355, 987, 1432, 1213, 1564, 1301, 2621, 1884, 1951, 1762, 1588, 2445, 1040, 390, 1624, 2685, 988, 1937, 1057, 1433, 1979, 811, 2313, 605, 1240, 1367, 1770, 1504, 1313, 742, 788, 849, 1905, 1813, 715, 2487, 1891, 1347, 2010, 932, 488, 2317, 1675, 2604, 1751, 1685, 619, 1297, 1886, 981, 1521, 1016, 2269, 746, 1444, 2377, 1360, 2657, 657, 592, 2708, 436, 711, 283, 548, 601, 1191, 1728, 1676, 518, 2121, 1845, 405, 2414, 1922, 2557, 382, 838, 2589, 882, 1222, 1125, 1896, 563, 2213, 442, 239, 1704, 2133, 315, 841, 1394, 1150, 459, 1063, 444, 274, 474, 631, 2259, 2101, 2140, 642, 433, 2584, 1828, 543, 1449, 1450, 869, 837, 719, 5, 2695, 789, 661, 2276, 1340, 1766, 1357, 432, 254, 625, 656, 1292, 2104, 1795, 1816, 1799, 2246, 1457, 2661, 1220, 1343, 2087, 1940, 353, 1663, 2591, 725, 1106, 971, 2356, 1572, 855, 1138, 1368, 1908, 828, 2036, 1529, 2622, 1612, 669, 675, 2690, 709, 708, 409, 1376, 2314, 389, 641, 702, 1844, 2284, 558, 2538, 1385, 951, 2127, 269, 2063, 761, 567, 955, 1247, 1686, 2250, 2088, 460, 393, 557, 1921, 1472, 2648, 1068, 2157, 2566, 1287, 2674, 862, 501, 2379, 246, 1788, 267, 1111, 2386, 402, 2129, 1112, 2594, 2365, 1775, 1241, 678, 1214, 2171, 1038, 1645, 2166, 275, 371, 990, 726, 1994, 677, 1, 666, 682, 1797, 372, 1580, 1950, 2106, 2094, 671, 422, 327, 1870, 259, 1266, 2029, 1794, 1206, 2242, 2632, 1837, 2463, 503, 2258, 2042, 808, 1695, 832, 2613, 1199, 2446, 1074, 1080, 2415, 2125, 2263, 2306, 1087, 1532, 2182, 606, 801, 756, 1124, 872, 1269, 2055, 1043, 1048, 1465, 2389, 1640, 1864, 2228, 1578, 1920, 2574, 1295, 2255, 774, 1335, 714, 1742, 1871, 839, 1829, 1984, 526, 559, 1914, 1473, 2673, 812, 633, 900, 1927, 1489, 763, 2168, 2376, 752, 2554, 2059, 853, 243, 2164, 672, 2092, 1715, 1858, 533, 1175, 1555, 1317, 886, 1527, 689, 893, 1804, 2526, 2531, 819, 2217, 813, 2333, 2184, 2186, 970, 1759, 2649, 1285, 1632, 1903, 1747, 1734, 946, 2072, 1917, 800, 1530, -1, 1141, 2079, 1892, 2114, 566, 2078, 737, 1698, 2372, 2338, 610, 782, 2624, 2343, 1630, 1607, 1830, 690, 1499, 1460, 1561, 1930, 1790, 889, 2626, 1941, 2585, 2027, 2045, 1006, 278, 2406, 416, 377, 1517, 1235, 1893, 1052, 256, 809, 1869, 1839, 1815, 1501, 881, 1956, 542, 1344, 1342, 1128, 262, 1312, 1050, 1764, 1942, 2385, 2655, 2682, 545, 487, 1767, 1510, 1696, 2280, 831, 1983, 2176, 604, 1646, 842, 2218, 2350, 2374, 1805, 1615, 336, 724, 826, 1055, 1642, 2400, 1392, 1169, 1565, 1291, 334, 1238, 2402, 552, 2235, 1711, 1309, 1851, 1221, 607, 387, 1610, 1560, 2473, 1977, 999, 1041, 1714, 2335, 2128, 2727, 2393, 993, 525, 1636, 1724, 1147, 2272, 810, 1311, 1398, 1668, 857, 1890, 2410, 2718, 1286, 960, 929, 2638, 2689, 1404, 1583, 495, 2321, 1593, 2198, 1390, 1970, 1086, 1931, 1558, 1713, 1866, 1471, 1585, 2382, 2595, 2039, 824, 1988, 2190, 1305, 873, 944, 2660, 2001, 1722, 2271, 1455, 1037, 1687, 2394, 1395, 1540, 527, 773, 1608, 1456, 260, 231, 1424, 328, 1331, 263, 1042, 1848, 1692, 2316, 2135, 1143, 1545, 2203, 1092, 1614, 1369, 1627, 836, 1519, 1419, 2491, 2301, 2082, 265, 996, 1162, 2109, 910, 238, 1936, 765, 1299, 2233, 554, 2694, 2248, 2555, 662, 2216, 1875, 2474, 2132, 1377, 827, 2392, 1899, 1556, 779, 1997, 817, 321, 1337, 614, 1656, 2201, 2567, 1109, 582, 777, 1826, 898, 796, 1498, 1772, 1782, 1702, 1840, 2212, 1758, 1985, 919, 361, 2596, 1246, 1386, 1924, 2569, 261, 2641, 348, 1064, 868, 1215, 965, 1712, 1223, 1232, 1500, 484, 569, 1673, 1276, 233, 1863, 2498, 2277, 2637, 2701, 2017, 1605, 897, 1935, 498, 1184, 1435, 1186, 1387, 673, 2295, 679, 2337, 493, 775, 1536, 759, 258, 398, 966, 1678, 1889, 704, 1959, 2287, 2413, 1107, 2172, 2368, 244, 1657, 722, 1330, 1078, 1876, 2180, 1230, 1430, 1402, 959, 1625, 693, 2520, 1563, 871, 329, 1422, 1631, 439, 2294, 991, 1338, 1110, 2011, 2200, 309, 1651, 717, 799, 2364, 1103, 2110, 447, 1814, 2264, 934, 249, 1446, 316, 2509, 721, 2532, 703, 660, 1938, 2544, 2244, 2236, 529, 2612, 502, 1807, 1969, 248, 1025, 2099, 1507, 1523, 1514, 463, 539, 2403, 517, 1769, 2443, 242, 1380, 342, 236, 888, 294, 257, 1409, 1703, 2440, 583, 568, 998, 1391, 768, 1803, 978, 2560, 1720, 1061, 1750, 611, 2120, 1923, 1638, 909, 790, 510, 747, 982, 771, 1401, 1187, 3, 2478, 2525, 1059, 1431, 2653, 1318, 584, 1329, 1316, 2529, 792, 867, 1682, 1302, 1667, 240, 538, 612, 2460, 2283, 2209, 1083, 1662, 449, 667, 1120, 706, 2503, 1897, 241, 357, 1129, 2421, 1416, 588, 419, 1345, 2650, 636, 2165, 2061, 1458, 2329, 2004, 1045, 891, 468, 1346, 2360, 952, 723, 1131, 401, 281, 1553, 718, 863, 1136, 2124, 1051, 2326, 1022, 1832, 2191, 1181, 1819, 2696, 232, 692, 739, 2103, 1934, 652, 535, 1952, 2274, 266, 683, 876, 1415, 699, 1271, 2260, 2354, 1244, 560, 940, 1761, 553, 2665, 2716, 2559, 2282, 1880, 2482, 2161, 1163, 2018, 2278, 1648, 2204, 1535, 1683, 1634, 509, 720, 769, 564, 247, 2434, 2320, 528, 1039, 2014, 544, 1113, 890, 1012, 1846, 945, 1731, 1909, 561, 1272, 1044, 2346, 1861, 1857, 2043, 911, 916, 1145, 491, 907, 757, 2494, 1421, 1827, 1088, 1379, 615, 285, 866, 497, 1468, 1838, 2658, 620, 486, 1069, 2147, 2221, 1933, 942, 2662, 2597, 805, 1718, 1207, 424, 1567, 843, 2154, 1509, 2643, 1690, 2325]
  user_ids = (user_without_registration_log_ids + user_without_credit_log_ids).uniq

  path_to_file = config["path_to_file"]

  puts "#{Time.now} - Getting users to fix"
  users = conn.exec("SELECT * FROM users WHERE id IN (#{user_ids.join(",")});")
  puts "#{users.count} users found to fix"

  puts "#{Time.now} - Getting data for users from events table"
  users_data_map = {}
  events_conn.exec(
    "SELECT DISTINCT ON (1) user_id, data 
    FROM events
    WHERE timestamp > '2015-09-01' 
    AND tenant = '#{config["tenant"]}' 
    AND message = 'http request start' 
    AND user_id IN (#{user_ids.join(",")});"
  ).each do |event|
    users_data_map[event["user_id"].to_s] = JSON.parse(event["data"])
  end
  puts "#{users_data_map.count} data for users found"

  puts "#{Time.now} - Starting files generation"

  users.each_with_index do |user, index|

    session_id = (1..32).map { ["a","b","c","d","e","f",0,1,2,3,4,5,6,7,8,9].sample }.join
    user_data = users_data_map[user["id"].to_s]
    if user_data.nil?
      puts "No data for user #{user['id']}"
      pid = 27601
      remote_ip = "2.228.97.250"
      app_server = "ip-172-31-11-221"
    else
      pid = user_data["pid"] # 27601
      remote_ip = user_data["remote_ip"] # "2.228.97.250"
      app_server = user_data["app_server"] # "ip-172-31-11-221"
    end

    created_at = DateTime.parse(user["created_at"], "%Y-%m-%d %H:%M:%S.%3N")

    http_req_start_time = add_ms(created_at, -89)
    email_sent_time = add_ms(created_at, 567)
    registration_time = add_ms(created_at, 569)
    assigning_reward_time = add_ms(created_at, 574)    
    http_req_end_time = add_ms(created_at, 579)

    http_request_start = {
      "message" => "http request start",
      "level" => "info",
      "data" => {
        "request_uri" => "/users",
        "method" => "POST",
        "http_referer" => "http://www.wellnessmachine.it/",
        "user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
        "lang" => "en-US,en;q=0.8,it-IT;q=0.6,it;q=0.4",
        "app_server" => app_server,
        "session_id" => "#{session_id}",
        "remote_ip" => "#{remote_ip}",
        "tenant" => "braun_ic",
        "user_id" => -1,
        "pid" => pid
      },
      "timestamp" => http_req_start_time,
      "pid" => pid
    }

    email_sent = {
      "message" => "email sent",
      "level" => "info",
      "data" => {
        "data" => nil
      },
      "timestamp"=> email_sent_time,
      "pid" => pid
    }

    registration = {
      "message" => "registration",
      "level" => "audit",
      "data" => {
        "form_data" => {
          "email" => user["email"],
          "privacy" => "1"
        },
        "user_id"=> user["id"]
      },
      "timestamp" => registration_time,
      "pid" => pid
    }

    assigning_reward_to_user = {
      "message" => "assigning reward to user",
      "level" => "audit",
      "data" => {
        "time" => 0.036126036,
        "interaction" => 74,
        "outcome_rewards" => {
          "credit" => 1
        },
        "outcome_unlocks" => [],
        "already_synced" => true
      },
      "timestamp" => assigning_reward_time,
      "pid" => pid
    }

    http_request_end = {
      "message" => "http request end",
      "level" => "info",
      "data" => {
        "request_uri" => "/users",
        "method" => "POST",
        "http_referer" => "http://www.wellnessmachine.it/",
        "user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
        "lang" => "en-US,en;q=0.8,it-IT;q=0.6,it;q=0.4",
        "app_server" => app_server,
        "session_id" => session_id,
        "remote_ip" => remote_ip,
        "tenant" => "braun_ic",
        "user_id" => -1,
        "pid" => pid,
        "status" => 302,
        "cache_hits" => 3,
        "cache_misses" => 0,
        "db_time" => 0.0035624769999999997,
        "view_time" => 0.0,
        "time" => "0.856805299"
      },
      "timestamp" => http_req_end_time,
      "pid" => pid
    }

    file_name = "#{path_to_file}/#{pid}-#{DateTime.now.strftime("%Y%m%d_%H%M%S_%6N")}#{index % 1000}-closed.log"

    File.open(file_name, "w") do |f| 
      f.truncate(0)
      f.write(http_request_start.to_json + "\n")
      f.write('{"message":"cache miss computation","level":"info","data":{"key":"f:braun_ic:rewarding_rules_collector_51","time":0.008581015},"timestamp":"' + add_ms(created_at, -79).to_s + '","pid":' + pid.to_s + '}' + "\n" + '{"message":"cache miss computation","level":"info","data":{"key":"f:braun_ic:current_periodicities","time":0.002183007},"timestamp":"' + add_ms(created_at, -69).to_s + '","pid":' + pid.to_s + '}' + "\n" + '{"message":"cache miss computation","level":"info","data":{"key":"f:braun_ic:model_helper.rb:5","time":0.002143178},"timestamp":"' + add_ms(created_at, -58).to_s + '","pid":' + pid.to_s + '}' + "\n")
      if user_without_registration_log_ids.include?(user["id"].to_s)
        f.write(email_sent.to_json + "\n")
        f.write(registration.to_json + "\n")
      end
      if user_without_credit_log_ids.include?(user["id"].to_s)
        f.write(assigning_reward_to_user.to_json + "\n")
      end
      f.write('{"message":"expiring cache key","level":"info","data":{"key":"f:braun_ic:cta_to_reward_statuses_' + user['id'] + '"},"timestamp":"' + add_ms(created_at, 575).to_s + '","pid":' + pid.to_s + '}' + "\n" + '{"message":"expiring cache key","level":"info","data":{"key":"f:braun_ic:status_reward_credit_' + user['id'] + '"},"timestamp":"' + add_ms(created_at, 576).to_s + '","pid":' + pid.to_s + '}' + "\n" + '{"message":"expiring cache key","level":"info","data":{"key":"f:braun_ic:rewards_credit_counter_for_user_' + user['id'] + '"},"timestamp":"' + add_ms(created_at, 577).to_s + '":' + pid.to_s + '}' + "\n" + '{"message":"cache miss computation","level":"info","data":{"key":"f:braun_ic:rewards_with_tag_to-be-notified","time":0.005173912},"timestamp":"' + add_ms(created_at, 578).to_s + '","pid":' + pid.to_s + '}' + "\n")
      f.write(http_request_end.to_json)
    end

    if (index + 1) % 50 == 0
      puts "#{Time.now} - #{index + 1} files generated"
    end
  end

  puts "#{Time.now} - All files generated. Total time: #{Time.now - start_time} seconds."

end

def add_ms(datetime, ms_delay)
  ms = datetime.strftime("%Q").to_i
  ms += ms_delay
  return DateTime.strptime(ms.to_s, "%Q").strftime("%Y-%m-%d %H:%M:%S.%3N")
end

main()