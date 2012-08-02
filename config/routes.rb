Virtualx::Application.routes.draw do
    
  get "errors/not_found"
resources :aboutus
resources :clientinfo
  resources :images 

  #get "images/index"
  #get "images/new"
  match '/view_aboutus' => 'home#view_aboutus'
  match '/view_clients' => 'home#view_clients'
  match '/view_features' => 'home#view_features'
  match '/view_modules' => 'home#view_modules'
  match '/view_contactus' => 'home#view_contactus'
  
  match '/deleteUsersubject' => 'users#deleteUsersubject'

match '/clientImage' => 'images#clientImage'
match '/createClientimage' => 'images#createClientimage'

  get "/questions/question_type_listing"
  post "/questions/new"
  resources :questions do
        member do
          get "delete_option"
      post "delete_option"
                get "delete_match_option"
      post "delete_match_option"
                      get "delete_matrix_row"
      post "delete_matrix_row"
                      get "delete_matrix_column"
      post "delete_matrix_column"
      get "delete_hrcl_option"
      post "delete_hrcl_option"
      
            get "saveImage"
      post "saveImage"
      
    end
  end
    #post "questions/publish_unpublish"
  #get "questions/publish_unpublish"
  match '/publish_unpublish' => 'questions#publish_unpublish'
  match '/unpublish' => 'questions#unpublish'
  match '/share' => 'questions#share' 

  match '/saveImage' => 'questions#saveImage'
   match '/sharewithCategory' => 'questions#sharewithCategory'
  match'/checkMark' => 'questions#checkMark'
   match'/viewQuestion' => 'questions#viewQuestion'
   
  get "subjects/add_subject_category"
  resources :subjects 
  
  post "subjects/cs"
  
  resources :categories
  resources :category_titles
  resources :emails  
    
  post "attend_exams/confirm_exam"
  get "attend_exams/confirm_exam"
  post "attend_exams/reject_exam"
  get "attend_exams/reject_exam"
  resources :attend_exams
  get "attend_exams/index"
  match '/examination' => 'attend_exams#examination'
  match '/instruction' => 'attend_exams#instruction'
  match '/evaluation' => 'attend_exams#evaluation'
  match '/evaluation' => 'attend_exams#ramdomizeQuestions'
   match '/examComplete' => 'attend_exams#examComplete'
   match '/calculateScore' => 'attend_exams#calculateScore'
   match '/windowClose' => 'attend_exams#windowClose'
   
   
   match 'welcome/examinee_dashboard' => 'welcome#examinee_dashboard'
  #get "exams/attend_exam"
  #post "exams/attend_exam"

  resources :exams 
  #  member do
      #get "exams/index"
  #  end
  #end
  match '/scheduleExam' => 'exams#scheduleExam'
  match '/selectQuestion' => 'exams#selectQuestion'
  match '/assignQustions' => 'exams#assignQustions'
  match '/selectExaminee' => 'exams#selectExaminee'
  match '/assignExaminees' => 'exams#assignExaminees'
  match '/previewExam' => 'exams#previewExam'
  match '/deleteExamQuestion' => 'exams#deleteExamQuestion'
  match '/deleteExamUser' => 'exams#deleteExamUser'
 match '/getMark' => 'exams#getMark'
 match '/assignExam' => 'exams#assignExam'
  match '/groupExam' => 'exams#groupExam'
 match '/updateMark' => 'exams#updateMark'
  match '/examtype' => 'exams#examtype'
   match '/create_examtype' => 'exams#create_examtype'
   match '/listExamtypes' => 'exams#listExamtypes'
  match '/editExamtype' => 'exams#editExamtype' 
   match '/deleteExamtype' => 'exams#deleteExamtype' 
   match '/updateExamtype' => 'exams#updateExamtype' 
match '/getExam' => 'exams#getExam'
 match '/showEvaluationtype' => 'exams#showEvaluationtype'
 match '/hideEvaluationtype' => 'exams#hideEvaluationtype'
 match '/evaluate' => 'exams#evaluate'
 match '/getExamQuestions' => 'exams#getExamQuestions'
 match '/manualEvaluation' => 'exams#manualEvaluation'
 match '/finishEvaluation' => 'exams#finishEvaluation'
 match '/getCategoryexams' => 'exams#getCategoryexams'
 match '/assignEvaluator' => 'exams#assignEvaluator'
  match '/getEvaluator' => 'exams#getEvaluator'
  match '/evaluator' => 'exams#evaluator'
  match '/delete_evaluator' => 'exams#delete_evaluator' 
  
 match '/completedExams' => 'attend_exams#completedExams'
 match '/pendingExams' => 'attend_exams#pendingExams'
 
 
  
  match '/updateCategory' => 'category_titles#updateCategory'
  match '/deleteCategory' => 'category_titles#deleteCategory'
  
  get "settings/index"

  get "feedback/index"
  match '/assign' => 'feedback#assign'
  match '/unassign' => 'feedback#unassign'
  match '/viewFeedback' => 'feedback#viewFeedback'
  match '/submitFeedback' => 'feedback#submitFeedback'
  match '/viewfeedbackResponse' => 'feedback#viewfeedbackResponse'
  match '/feedbackResponse' => 'feedback#feedbackResponse'
    

  get "reports/index"
  
  get "results/index"
  match '/usersResult' => 'results#usersResult'
  match '/resultIndex' => 'results#index'
  match '/viewUserResult' => 'results#viewUserResult'
  match '/groupResult' => 'results#groupResult'
  match '/examsResult' => 'results#examsResult'
  match '/viewExamResult' => 'results#viewExamResult'
  match '/departmentResult' => 'results#departmentResult'
  match '/viewDepartmentResult' => 'results#viewDepartmentResult'
  
  #get "examination/index"
  
 # get "reports/generateDepartmentReport"
  
  match '/userReport' => 'reports#userReport'
  match '/viewuserReport' => 'reports#viewuserReport'
 match '/examReport' => 'reports#examReport'
match '/viewexamReport' => 'reports#viewexamReport'
match '/generateUser' => 'reports#generateUser'
match '/userSubjectwise' => 'reports#userSubjectwise'
match '/generateExamReport' => 'reports#generateExamReport'
match '/departmentReport' => 'reports#departmentReport'
match '/viewDepartmentReport' => 'reports#viewDepartmentReport'
match '/generateDepartmentReport' => 'reports#generateDepartmentReport'
match '/viewDepartmentReportgraph' => 'reports#viewDepartmentReportgraph'
match '/highLevel' => 'reports#highLevel'
match '/reportYear' => 'reports#reportYear'
match '/overall' => 'reports#overall'
match '/specificDepartment' => 'reports#specificDepartment'
match '/departmentDetailed' => 'reports#departmentDetailed'
match '/semesterDetailed' => 'reports#semesterDetailed'
match '/pass_fail' => 'reports#pass_fail'
match '/generatePassfail' => 'reports#generatePassfail'
match '/fetchExam' => 'reports#fetchExam'

match '/listCategories' => 'categories#listCategories'
match '/delete_category' => 'categories#delete_category'



  get "questions/index"

  get "subjects/index"


  resources :settings
  resources :temporary_examinee
  #get "temporary_examinee/new"
  #get "temporary_examinee/create"
  #post "temporary_examinee/create"


  #get "user_registration/new"
  resources :user_registration

  
  #resources :welcome
  get "welcome/index"
  get "welcome/admin_dashboard"
  get "welcome/examiner_dashboard"
  get "welcome/qsetter_dashboard"
  get "welcome/examinee_dashboard"
  post "welcome/confirm_registration"
  get "welcome/confirm_registration"
  post "welcome/reject_registration"
  get "welcome/reject_registration"
  get "welcome/user_management"

  
  get "passwords/new"

  #get "passwords/forgot"
  match 'groupUser' => 'users#groupUser'
  match 'createGroup' => 'users#createGroup'
  get "user_sessions/new"

  get "users/new"
  get "users/generate_temporary_password"
  post "users/generate_temporary_password"
  match 'activate_inactivate' => 'users#activate_inactivate'
    match 'activate' => 'users#activate'
      match 'inactivate' => 'users#inactivate'
  #match 'users/tempexaminee' => 'users#new'

  resources :users 
  get "users/show"

  get "users/edit"
  
  
  get "home/index"

  get "user_sessions/new"
  resources :user_sessions
 
  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout
    
  #get "password_resets/new"
  resources :password_resets do
    member do
      get 'confirmEmail'
      get 'setPassword'
      get 'savePassword'
      post 'savePassword'
      get 'varifyPassword'      
    end
  end
  get "password_resets/edit"


 # post "password_resets/edit"

  get    'verify/:id'       => 'user_verifications#index'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
    root :to => 'home#index'
    resources :home
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
