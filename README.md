  OhUnWan(OhYakWan)은 사용자의 건강 데이터를 기반으로 개인화된 피드백을 제공하는 iOS 애플리케이션입니다.
  
  **HealthKit**과 **온디바이스 AI**를 결합하여 사용자의 약물 복용 및 신체 활동을 관리하고 동기를 부여합니다.
  

  핵심 기능

   - 약물 복용 추적: **HealthKit의 Medications API**와 연동하여 오늘 복용해야 할 약물과 이미 복용한 약물을 표시합니다.
   - 활동 데이터 연동: HKWorkout을 사용하여 최근 운동 기록을 가져옵니다. 각 운동 세션의 소모 칼로리, 지속 시간, 평균 심박수 등의 상세 데이터를 제공합니다.
   - 개인화된 AI 피드백: Apple의 **Foundation Models**를 활용하여 수집된 건강 데이터를 기반으로 맞춤형 조언을 생성합니다.
     모든 건강 데이터 분석은 사용자의 기기 내에서 온디바이스 AI로 처리됩니다.

  기술 구현

  1. HealthKit 데이터 연동

   - `HealthStore.swift`: 앱의 모든 HealthKit 관련 로직을 관리하는 중앙 클래스입니다.
     - Medications API: 사용자의 승인을 받아 Health 앱에 기록된 약물 복용 데이터를 가져옵니다.
     - HKWorkout: 최근 7일간의 운동 기록을 조회합니다.
       HKWorkout 객체에 포함된 statistics(for:) 메서드를 사용하여 각 운동 세션의 통계 데이터를 가져옵니다.

  2. 온디바이스 AI (Foundation Models)

   - `FoundationModelsService.swift`: Apple의 FoundationModels 프레임워크와 상호 작용하는 서비스 클래스입니다.
     - 동적 프롬프트 생성: HealthStore에서 가져온 약물 복용 현황, 운동 기록, 평균 심박수 등의 데이터를 바탕으로 AI 모델에 전달할 상세한 프롬프트를 동적으로 생성합니다.
     - 온디바이스 추론: 생성된 프롬프트를 기기 내 언어 모델 세션(LanguageModelSession)으로 전달하여 외부 서버 없이 응답을 생성합니다.

  3. SwiftUI 기반 UI

   - `MedicationListView.swift`: 복용 약물 목록과 복용 상태를 표시합니다.
   - `ActivityListView.swift`: 최근 운동 기록과 각 운동의 상세 정보를 표시합니다.
   - 데이터 흐름
     1. 사용자가 앱을 실행하면 HealthStore가 HealthKit 데이터를 가져와 @Observable 객체를 통해 UI를 업데이트합니다.
     2. 사용자가 'AI 피드백 받기' 버튼을 누르면 현재 HealthStore에 있는 데이터를 기반으로 FoundationModelsService가 AI 응답을 생성하여 화면에 표시합니다.

  요구사항
   - Xcode 23+
   - iOS 23+
   - MacOS 23+ (Foundation Models)

  실행 방법
   1. 프로젝트를 Xcode에서 엽니다.
   2. 실제 기기를 타겟으로 설정합니다.
   3. 앱을 빌드하고 실행합니다.
   4. 앱이 HealthKit 데이터 접근 권한을 요청하면 승인합니다. (테스트를 위해 Health 앱에 약물 및 운동 데이터가 미리 기록되어 있어야 합니다.)
