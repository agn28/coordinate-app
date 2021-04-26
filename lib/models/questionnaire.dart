import 'package:intl/intl.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';

var _questions = {
    'tobacco': {
      'items' : [
        {
          'question': 'Have you used tobacco (all forms – cigarettes, biri, chewing tobacco, zarda, gul) during the past 12 months?',
          'question_bn': 'আপনি কি গত ১২ মাসে তামাক (সমস্ত ধরণের - সিগারেট, বিড়ি, তামাকপাতা, জর্দা, গুল) ব্যবহার করেছেন?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Were you regularly exposed to secondhand tobacco smoke in the past 12 months?',
          'question_bn': 'আপনি কি গত ১২ মাসে নিয়মিতভাবে তামাকের ধোঁয়ার সংস্পর্শে এসেছিলেন?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
      ]
    },
    'alcohol': {
      'items' : [
        {
          'question': 'Did you drink any alcohol in the last 30 days?',
          'question_bn': 'আপনি গত ৩০ দিনে কোনও অ্যালকোহল পান করেছেন?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'How many days in the last 30 days?',
          'question_bn': 'গত ৩০ দিনের মধ্যে কত দিন?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'How many standard drinks units per day?',
          'question_bn': 'প্রতিদিন কত স্ট্যান্ডার্ড পানীয় ইউনিট?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        }
      ]
    },
    'diet': {
      'items' : [
        {
          'question': 'Do you eat at least 5 portions of fruit and vegetables (excluding starchy vegetables) daily? (1 serving = 0.5 cup cooked vegetables or 1 cup raw vegetables; 1 orange, apple, banana, mango)',
          'question_bn': 'আপনি কি প্রতিদিন কমপক্ষে ৫ ভাগ ফলমূল এবং শাকসব্জি (স্টার্চযুক্ত সবজি বাদে) খান? (১পরিবেশন = ০.৫ কাপ রান্না করা শাকসব্জী বা ১ কাপ কাঁচা শাকসব্জী; ১ কমলা, আপেল, কলা, আমের)',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Do you eat red meat, fried foods, canned or other processed foods on most days?',
          'question_bn': 'আপনি কি বেশিরভাগ দিন লাল মাংস, ভাজা খাবার, টিনজাত বা অন্যান্য প্রক্রিয়াজাত খাবার খান?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Do you have sugary drinks (for example, soda, juice, sweetened milk) on most days?',
          'question_bn': 'আপনার কি বেশিরভাগ দিন মিষ্টি পানীয় (যেমন - সোডা, জুস, মিষ্টি দুধ) পান করেন?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Do you add extra salt to your meals?',
          'question_bn': 'আপনি কি আপনার খাবারে অতিরিক্ত লবণ খান?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        }
      ],
    },
    'physical_activity': {
      'items' : [
        {
          'question': 'Do you do physical activity of moderate intensity i.e. you get a little bit out of breath, for at least 30 minutes per day on 5 days per week, or for 150 minutes per week?',
          'question_bn': 'আপনি কি প্রতি সপ্তাহে ৫ দিন প্রতিদিন কমপক্ষে ৩০ মিনিট, বা প্রতি সপ্তাহে ১৫০ মিনিট তীব্র মাত্রার শারীরিক পরিশ্রম করেন যেখানে শ্বাসপ্রশ্বাস দ্রুত হয়?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Do you spend more than 5 hours sitting down every day?',
          'question_bn': 'আপনি কি প্রতিদিন ৫ ঘন্টার বেশি সময় বসে কাটান বা বসে বসে কাজ করেন?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
      ]
    },

    'current_medication': {
      'items' : [
        {
          'question': 'What medications are you taking (including over-the-counter /herbal /traditional remedies/recreational)?',
          'question_bn': 'আপনি কী কী ওষুধ খাচ্ছেন (ফার্মেসী থেকে কেনা / ভেষজ / প্রচলিত ওষুধ / বিনোদনমূলক)?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Are you taking your medications exactly as prescribed?',
          'question_bn': 'আপনি কি ওষুধগুলি প্রেসক্রিপশনে দেয়া নিয়ম অনুযায়ী খাচ্ছেন?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'What problems have you had taking your medicines?',
          'question_bn': 'ওষুধ সেবন করতে আপনার কি কি সমস্যা হচ্ছে?',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
      ]
    },

    'medical_history': {
      'items' : [
        {
          'question': 'Heart attack/angina/other heart diseases (e.g. heart failure, rheumatic heart disease)',
          'question_bn': 'হার্ট অ্যাটাক / এনযাইনা / অন্যান্য হৃদরোগ (যেমনঃ হার্ট ফেইলিউর, রিউম্যাটিক হার্ট ডিজিজ)',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Stroke/ transient ischaemic attack (TIA)',
          'question_bn': 'স্ট্রোক / টিআইএ',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'High blood pressure (hypertension)',
          'question_bn': 'উচ্চ রক্তচাপ (হাইপারটেনশন)',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'High blood sugar (diabetes)',
          'question_bn': 'রক্তে উচ্চ শর্করা (ডায়াবেটিস)',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'High blood cholesterol or dyslipidemia',
          'question_bn': 'রক্তের উচ্চ  কোলেস্টেরল বা ডিসলিপিডেমিয়া',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Kidney disease',
          'question_bn': 'কিডনী রোগ',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Other illnesses such as tuberculosis, HIV (confirm HIV status, testing as per national guidelines)',
          'question_bn': 'অন্যান্য অসুস্থতা যেমন- যক্ষ্মা, এইচআইভি  (এইচআইভি আছে কিনা নিশ্চিত হন, জাতীয় নির্দেশিকা অনুযায়ী পরীক্ষা করা হয়েছে কিনা)',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
        {
          'question': 'Do you have any allergies?',
          'question_bn': 'আপনার কি কোনও এলার্জি আছে??',
          'type': 'allergy',
          'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না']
        },
      ]
    },

    'new_patient': {
      'medical_history': {
        'items' : [
          // {
          //   'question': 'Does anyone in your family have high blood pressure or diabetes?',
          //   'question_bn': 'আপনার পরিবারের কারও কি উচ্চ রক্তচাপ বা ডায়াবেটিস আছে?',
          //   'options': ['yes', 'no'],
          //   'options_bn': ['হ্যা', 'না'],
          //   'key': 'relative_disease'
          // },
          {
            'question': 'Have you ever been diagnosed with Stroke?',
            'question_bn': 'আপনার কি কখনও স্ট্রোক হয়েছে?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'stroke',
            'key': 'stroke'
          },
          {
            'question': 'Have you ever been diagnosed with heart attack?',
            'question_bn': 'আপনার কি কখনও হার্ট অ্যাটাক হয়েছে?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'heart',
            'key': 'heart_attack'
          },
          {
            'question': 'Have you ever been diagnosed with hypertension?',
            'question_bn': 'আপনার কি কখনও উচ্চ রক্তচাপ ধরা পড়েছে?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'blood_pressure',
            'key': 'hypertension'
          },
          {
            'question': 'Have you ever been diagnosed with Diabetes?',
            'question_bn': 'আপনার কি কখনও ডায়াবেটিস ধরা পড়েছে?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'diabetes',
            'key': 'diabetes'
          },
          {
            'question': 'Have you ever been diagnosed with asthma/COPD?',
            'question_bn': 'আপনার কি কখনও হাঁপানি / সিওপিডি (ফুস্ফুসের দীর্ঘমেয়াদী শ্বাসকষ্টজনিত রোগ ধরা পড়েছে?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'asthma',
            'key': 'asthma'
          },
          {
            'question': 'Have you ever been diagnosed with Cancer?',
            'question_bn': 'আপনার কি কখনও ক্যান্সার ধরা পড়েছে?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'cancer',
            'key': 'cancer'
          },
          {
            'question': 'Have you ever been diagnosed with chronic kidney disease?',
            'question_bn': 'আপনার কি কখনও দীর্ঘস্থায়ী কিডনি রোগ ধরা পড়েছে?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'kidney_disease',
            'key': 'kidney_disease'
          },
        ]
      },
      'medication': {
        'items' : [
          {
            'question': 'Are you taking any medicines for hypertension?',
            'question_bn': 'আপনি ব্লাড-প্রেসার বা উচ্চ রক্তচাপের জন্য কোনও ওষুধ খাচ্ছেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'blood_pressure',
            'key': 'hypertension_medicine'
            
          },
          {
            'question': 'Are you taking the medicines regularly?',
            'question_bn': 'আপনি কি নিয়মিত ওষুধ খাচ্ছেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'blood_pressure_regular_medication',
            'category': 'sub',
            'key': 'hypertension_regular_medicine'
          },
          {
            'question': 'Are you taking any medicines for diabetes?',
            'question_bn': 'আপনি কি ডায়াবেটিসের কোনও ওষুধ খাচ্ছেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'diabetes',
            'key': 'diabetes_medicine',
          },
          {
            'question': 'Are you taking the medicines regularly?',
            'question_bn': 'আপনি কি নিয়মিত ওষুধ খাচ্ছেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'diabetes_regular_medication',
            'category': 'sub',
            'key': 'diabetes_regular_medicine',
          },
          {
            'question': 'Are you taking any aspirin/clopidegrol?',
            'question_bn': 'আপনি কি কোনও অ্যাসপিরিন / ক্লপিডগ্রেল জাতীয় ওষুধ খাচ্ছেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'heart',
            'key': 'aspirin_medicine',
          },
          {
            'question': 'Are you taking the medicines regularly?',
            'question_bn': 'আপনি কি নিয়মিত ওষুধ খাচ্ছেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'heart_regular_medication',
            'category': 'sub',
            'key': 'aspirin_regular_medicine',
          },

          {
            'question': 'Are you taking any drug for lowering fat in blood (Cholesterol)?',
            'question_bn': 'রক্তে ফ্যাট (কোলেস্টেরল) কমাতে আপনি কি কোনও ওষুধ খাচ্ছেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'heart_bp_diabetes',
            'key': 'cholesterol_medicine',
          },
          {
            'question': 'Are you taking the medicines regularly?',
            'question_bn': 'আপনি কি নিয়মিত ওষুধ খাচ্ছেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'type': 'heart_bp_diabetes_regular_medication',
            'category': 'sub',
            'key': 'cholesterol_regular_medicine',
          }
        ]

      },

      'risk_factors': {
        'items' : [
          {
            'question': 'Do you currently smoke biri or cigarate?*',
            'question_bn': 'আপনি কি বর্তমানে সিগারেটে বিড়ি ধূমপান করেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'tobacco',
            'type': 'smoking',
            'key': 'smoking'
          },
          {
            'question': 'Do you currently consume any smokeless tobacco such as sada pata, jarda, gul, khaini etc?*',
            'question_bn': 'আপনি বর্তমানে কোনও ধোঁয়াবিহীন তামাক (যেমন সাদ পাতা, জর্দা, গুল, খাইনি ইত্যাদি) সেবন করেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'tobacco',
            'type': 'smokeless-tobacco',
            'key': 'smokeless_tobacco'
          },
          {
          'question': 'Do you take betel nut  regularly?',
          'question_bn': 'আপনি কি নিয়মিত সুপারি খান?',
          'options': ['yes', 'no'],
          'options_bn': ['হ্যা', 'না'],
          'group': 'unhealth-diet',
          'type': 'rbetel-nut',
          'key': 'betel_nut'
          },
          {
            'question': 'Do you eat atleast 5 portions of fruits and vegetables daily?',
            'question_bn': 'আপনি কি প্রতিদিন কমপক্ষে ৫ ভাগ ফল এবং শাকসব্জী খান?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealth-diet',
            'type': 'eat-vegetables',
            'key': 'fruits_vegetables_daily'
          },
          // {
          //   'question': 'Do you eat any red meat, fried foods, canned or processed food on most days?',
          //   'question_bn': 'আপনি কি বেশিরভাগ দিন কোনও লাল মাংস, ভাজা খাবার, টিনজাত বা প্রক্রিয়াজাত খাবার খান?',
          //   'options': ['yes', 'no'],
          //   'options_bn': ['হ্যা', 'না']
          // },
          {
            'question': 'Do you take added salt in your food?',
            'question_bn': 'আপনি কি আপনার খাবারে অতিরিক্ত লবণ যুক্ত করেন বা বেশিরভাগ দিন অতিরিক্ত লবণ বা নোনতা খাবার খান?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'key': 'extra_salt'
          },
          {
            'question': 'Do you frequently eat salty foods such as sauce, achar, singara, samucha, etc?',
            'question_bn': 'আপনি কি নিয়মিত লবনাক্ত খাবার খান, যেমনঃ সস, আচার, সিঙ্গারা, সমুচা?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealth-diet',
            'type': 'salt',
            'key': 'salty_foods'
          },
          {
            'question': 'Do you have sugary drinks on most days?',
            'question_bn': 'আপনি কি বেশিরভাগ সময়ে চিনিযুক্ত পানীয় পান করেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealth-diet',
            'type': 'suger',
            'key': 'sugary_drinks'
          },
          {
            'question': 'Do you frequently eat processed food such as chips, chanachur, biscuit, noodles etc?',
            'question_bn': 'আপনি কি নিয়মিত প্রক্রিয়াজাত খাবার খান (যেমন চিপস, চানাচুর, বিস্কুট ইত্যাদি?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealth-diet',
            'type': 'processed-food',
            'key': 'processed_foods'
          },
          {
            'question': 'Do you frequently eat red meat?',
            'question_bn': 'আপনি কি নিয়মিত লাল গোস্ত খান?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealth-diet',
            'type': 'red-meat',
            'key': 'red_meat'
          },
          {
            'question': 'Do you do physical activity of moderate intensity (you get a little bit out of breath) for atleast 30 minutes per day on 5 days per week or 150 minutes per week?',
            'question_bn': 'আপনি কি প্রতি সপ্তাহে ৫ দিন প্রতিদিন কমপক্ষে ৩০ মিনিট, বা প্রতি সপ্তাহে ১৫০ মিনিট মাঝারি থেকে তীব্র মাত্রার শারীরিক পরিশ্রম করেন যেখানে শ্বাসপ্রশ্বাস দ্রুত হয়?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'physical-activity',
            'type': 'physical-activity-high',
            'key': 'physical_activity_moderate'
          },
          {
            'question': 'Do you do physical activity of high intensity (you get out of breath) for at least 15 minutes per day on 5 days per week, or 75 minutes per week?',
            'question_bn': 'আপনি কি প্রতি সপ্তাহে ৫ দিন প্রতিদিন কমপক্ষে ১৫ মিনিট, বা প্রতি সপ্তাহে ৭৫ মিনিট তীব্র মাত্রার শারীরিক পরিশ্রম করেন যেখানে শ্বাসপ্রশ্বাস দ্রুত হয়?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'physical-activity',
            'type': 'physical-activity-moderate',
            'key': 'physical_activity_high'
          },
          {
            'question': 'Do you currently drink alcohol?',
            'question_bn': 'আপনি কি বর্তমানে মদ পান করেন?',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'alcohol',
            'type': 'alcohol-status',
            'key': 'alcohol'
          },
        ]
      },

      'counselling_provided': {
        'items' : [
          {
            'question': 'Smoking',
            'question_bn': 'ধূমপান',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'tobacco',
            'type': 'smoking'
          },
          {
            'question': 'Smokeless Tobacco',
            'question_bn': 'ধোঁয়াহীন তামাক',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'tobacco',
            'type': 'smokeless-tobacco'
          },
          {
            'question': 'Fruits and vegetables intake',
            'question_bn': 'ফল ও শাকসবজি গ্রহণ',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealthy-diet',
            'type': 'eat-vegetables'
          },
          {
            'question': 'Salt',
            'question_bn': 'লবণ',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealthy-diet',
            'type': 'salt'
          },
          {
            'question': 'Sugar',
            'question_bn': 'চিনি',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealthy-diet',
            'type': 'suger'
          },
          {
            'question': 'Processed food',
            'question_bn': 'প্রক্রিয়াজাত খাবার',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealth-diet',
            'type': 'processed-food'
          },
          {
            'question': 'Red meat',
            'question_bn': 'লাল গোস্ত',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'unhealthy-diet',
            'type': 'red-meat'
          },
          {
            'question': 'Physical activity',
            'question_bn': 'শারীরিক পরিশ্রম',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'physical-activity',
            'type': 'physical-activity-high'
          },
          {
            'question': 'Medical adherence',
            'question_bn': 'চিকিৎসা-পরামর্শ',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'medical-adherence',
            'type': 'medical-adherence'
          },
          {
            'question': 'Alcohol consumption',
            'question_bn': 'মদ পান',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'group': 'alcohol',
            'type': 'alcohol-status'
          },
        ]
      },


      'relative_problems': {
        'items' : [
          {
            'question': 'Stroke',
            'question_bn': 'স্ট্রোক',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'key': 'stroke'
            
          },
          {
            'question': 'Heart Attack',
            'question_bn': 'হার্ট অ্যাটাক',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'key': 'heart_attack'
          },
          {
            'question': 'High Blood Pressure',
            'question_bn': 'উচ্চ্ রক্তচাপ',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'key': 'high_blood_pressure'
          },
          {
            'question': 'Diabetes',
            'question_bn': 'ডায়াবেটিস',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'key': 'diabetes'
          },
          {
            'question': 'Asthma/COPD',
            'question_bn': 'হাঁপানি / সিওপিডি',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'key': 'asthma'
          },
          {
            'question': 'Cancer',
            'question_bn': 'ক্যান্সার',
            'options': ['yes', 'no'],
            'options_bn': ['হ্যা', 'না'],
            'key': 'cancer'
          },
        ]

      },
    }
    
};

var _qnItems = [];

List _questionnaireItems = [];
var _alcoholItems = {};
var _tobaccoItems = {};
List _physicalActivityItems = [];
List _medicalHistoryItems = [];

class Questionnaire {

  /// Add questionnnaire answers
  /// [type], [comment] are required
  addQuestionnaire(type, answers) {
    var questions = Questionnaire().questions[type];
    var data = [];
    return;

    questions['items'].forEach((item) {
      _qnItems.add(_prepareData(questions, item, answers, type));
    });

    return 'success';
  }

  addQnItemsForEdit(observation) {
    _questionnaireItems.add(observation);
    _qnItems.add(observation['body']['data']);
  }

  addTobacco(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareTobaccoData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareTobaccoData(questions, answers, type));
    }

    return 'success';
  }

  addPhysicalActivity(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _preparePhysicalActivityData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_preparePhysicalActivityData(questions, answers, type));
    }
    
    return 'success';
  }

  addMedicalHistory(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareMedicalHistoryData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareMedicalHistoryData(questions, answers, type));
    }

    return 'success';
  }

  addCurrentMedication(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareCurrentMedicationData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareCurrentMedicationData(questions, answers, type));
    }
    
    return 'success';
  }

  addVideoSurvey(url, careplan) {

    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'video_watched': true,
          'url': url,
          'care_plan_id': careplan['id'],
          'title': careplan['body']['title']
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };
    // _questionnaireItems = [];
    // print(data['body']['data']['url']);

    print(_questionnaireItems.where((item) => item['body']['data']['url'] == url).isEmpty);
    if (_questionnaireItems.where((item) => item['body']['data']['url'] == url).isEmpty) {
      _questionnaireItems.add(data);
    }
    
    print(_questionnaireItems);
    return 'success';
  }

  addCounselling(withFramework, careplan) {

    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          '5a_framework': withFramework,
          'care_plan_id': careplan['id'],
          'title': careplan['body']['title']
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };
    // _questionnaireItems = [];
    // print(data['body']['data']['url']);

    _questionnaireItems.add(data);
    
    print(_questionnaireItems);
    return 'success';
  }

  addDiet(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareDietData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareDietData(questions, answers, type));
    }
    
    return 'success';
  }

  addAlcohol(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;
    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        answers.length == 1 ? _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNonAlcoholData(questions, answers, type) : _questionnaireItems[_questionnaireItems.indexOf(qn)] = _alcoholItems = _prepareAlcoholData(questions, answers, type); 
        updated = true;
      } 
    }

    if (!updated) {
      answers.length == 1 ? _questionnaireItems.add(_prepareNonAlcoholData(questions, answers, type)) : _questionnaireItems.add(_prepareAlcoholData(questions, answers, type));
    }
    
    return 'success';
  }

  addNewMedicalHistory(type, answers) {
    var questions = Questionnaire().questions['new_patient'][type];
    var updated = false;


    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['name'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNewMedicalData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareNewMedicalData(questions, answers, type));
    }
    
    return 'success';
  }

  addNewMedicalHistoryNcd(type, answers) {
    var questions = Questionnaire().questions['new_patient'][type];
    var updated = false;


    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['name'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNewMedicalDataNcd(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareNewMedicalDataNcd(questions, answers, type));
    }
    
    return 'success';
  }

  addNewMedication(type, answers) {
    var questions = Questionnaire().questions['new_patient'][type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['name'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNewMedicationData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareNewMedicationData(questions, answers, type));
    }
    
    return 'success';
  }

  addNewMedicationNcd(type, answers) {
    var questions = Questionnaire().questions['new_patient'][type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['name'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNewMedicationDataNcd(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareNewMedicationDataNcd(questions, answers, type));
    }
    
    return 'success';
  }

  addNewRiskFactors(type, answers) {
    var questions = Questionnaire().questions['new_patient'][type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['name'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNewRiskData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareNewRiskData(questions, answers, type));
    }
    
    return 'success';
  }

  addNewRiskFactorsNcd(type, answers) {
    var questions = Questionnaire().questions['new_patient'][type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['name'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNewRiskDataNcd(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareNewRiskDataNcd(questions, answers, type));
    }
    
    return 'success';
  }

  addNewCounselling(type, answers) {
    var questions = Questionnaire().questions['new_patient'][type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['name'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNewCounsellingData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareNewCounsellingData(questions, answers, type));
    }
    print(_prepareNewCounsellingData(questions, answers, type));
    
    return 'success';
  }

  addNewPersonalHistory(type, answers, additionalData) {
    var questions = Questionnaire().questions['new_patient'][type];
    var updated = false;
    var preparedData = _prepareRelativeData(questions, answers, type);
    preparedData['body']['data'].addAll(additionalData);
    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['name'] == type) {
        
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = preparedData;
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(preparedData);
    }
    print(preparedData);
    
    return 'success';
  }

  /// Prepare questionnaire data
  _prepareCurrentMedicationData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'medications': answers[0],
          'as_prescribed': answers[1],
          'problems_by_taking_medicines': answers[2],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  _prepareNonAlcoholData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'last_30_days': answers[0],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  _prepareAlcoholData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'last_30_days': answers[0],
          'days': int.parse(answers[1]),
          'units_per_day': int.parse(answers[2]),
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  _prepareTobaccoData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'last_12_months': answers[0],
          'secondhand_smoke': answers[1]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data
  _prepareDietData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'fruits_vegitables_daily': answers[0],
          'processed_foods': answers[1],
          'sugary_drinks': answers[2],
          'extra_salt': answers[3]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

    /// Prepare questionnaire data
  _prepareNewMedicalData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'diabetes': answers[0],
          'stroke': answers[1],
          'heart_attack': answers[2],
          'asthma': answers[3],
          'kidney_disease': answers[4],
          'cancer': answers[5],
          'hypertension': answers[6],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }
        //   "data": {
        //   'name': type,
        //   'diabetes': answers[0],
        //   'stroke': answers[1],
        //   'heart_attack': answers[2],
        //   'asthma': answers[3],
        //   'kidney_disease': answers[4],
        //   'cancer': answers[5],
        //   'hypertension': answers[6],
        // },

  /// Prepare questionnaire data for NCD
  _prepareNewMedicalDataNcd(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'stroke': answers[0],
          'heart_attack': answers[1],
          'hypertension': answers[2],
          'diabetes': answers[3],
          'asthma': answers[4],
          'cancer': answers[5],
          'kidney_disease': answers[6],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data
  _preparePhysicalActivityData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'physical_activity': answers[0],
          'sitting_more_than_5_hours': answers[1]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data
  _prepareMedicalHistoryData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'heart_disease': answers[0],
          'stroke': answers[1],
          'high_blood_pressure': answers[2],
          'diabetes': answers[3],
          'high_blood_cholesterol': answers[4],
          'kidney_disease': answers[5],
          'other_ilness': answers[6],
          'allergies': answers[7],
          'allergy_types': answers[8],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data
  _prepareNewMedicationData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'hypertension_medicine': answers[0],
          'hypertension_regular_medicine': answers[1],
          'diabetes_medicine': answers[2],
          'diabetes_regular_medicine': answers[3],
          'aspirin_medicine': answers[4],
          'aspirin_regular_medicine': answers[5],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data New
  _prepareNewMedicationDataNcd(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'hypertension_medicine': answers[0],
          'hypertension_regular_medicine': answers[1],
          'diabetes_medicine': answers[2],
          'diabetes_regular_medicine': answers[3],
          'aspirin_medicine': answers[4],
          'aspirin_regular_medicine': answers[5],
          'cholesterol_medicine': answers[6],
          'cholesterol_regular_medicine': answers[7],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

 /// Prepare questionnaire data
  _prepareNewRiskData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'smoking': answers[0],
          'smokeless_tobacco': answers[1],
          'alcohol': answers[2],
          'fruits_vegitables_daily': answers[3],
          'processed_foods': answers[4],
          'sugary_drinks': answers[5],
          'extra_salt': answers[6],
          'physical_activity_moderate': answers[7],
          'physical_activity_high': answers[8],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data for NCD
  _prepareNewRiskDataNcd(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'smoking': answers[0],
          'smokeless_tobacco': answers[1],
          'betel_nut': answers[2],
          'fruits_vegetables_daily': answers[3],
          'extra_salt': answers[4],
          'salty_foods': answers[5],
          'sugary_drinks': answers[6],
          'processed_foods': answers[7],
          'red_meat': answers[8],      
          'physical_activity_moderate': answers[9],
          'physical_activity_high': answers[10],
          'alcohol': answers[11],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

        //  "data": {
        //   'name': type,
        //   'smoking': answers[0],
        //   'smokeless_tobacco': answers[1],
        //   'fruits_vegetables_daily': answers[2],
        //   'extra_salt': answers[3],
        //   'salty_foods': answers[4],
        //   'sugary_drinks': answers[5],
        //   'processed_foods': answers[6],
        //   'red_meat': answers[7],
        //   'betel_nut': answers[8],
        //   'physical_activity_moderate': answers[9],
        //   'physical_activity_high': answers[10],
        //   'alcohol': answers[11],
        // },

  _prepareNewCounsellingData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'smoking': answers[0],
          'smokeless_tobacco': answers[1],
          'fruits_vegitables_daily': answers[2],
          'extra_salt': answers[3],
          'sugary_drinks': answers[4],
          'processed_foods': answers[5],
          'red_meat': answers[6],
          'physical_activity_moderate': answers[7],
          'medical_adherence': answers[9],
          'alcohol': answers[9],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }
  _prepareRelativeData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'stroke': answers[0],
          'heart_attack': answers[1],
          'high_blood_pressure': answers[2],
          'diabetes': answers[3],
          'asthma': answers[4],
          'cancer': answers[5]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }


  /// Prepare questionnaire data
  _prepareData(questions, item, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'question': item['question'],
          'answer': answers[questions['items'].indexOf(item)]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  isCompleted(type) {
    type = type.replaceAll(' ', '_').toLowerCase();
    for(var item in _questionnaireItems) {
      if (item['body']['data']['name'] == type) {
        return true;
      }
    }
    return false;
  }

  /// Get all answers
  List get qnItems {
    return [..._questionnaireItems];
  }

  clearItems() {
    _questionnaireItems = [];
  }

  // Get all questions
  get questions  {
    return _questions;
  }
}
