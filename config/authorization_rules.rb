 authorization do  
   role :admin do  
     has_permission_on [:welcome], :to => [:user_management,:index,:admin_dashboard,:examiner_dashboard,:qsetter_dashboard,:examinee_dashboard,:confirm_registration,:reject_registration]     
     has_permission_on [:users], :to => [:deleteUsersubject,:index, :show, :new, :create, :edit, :update, :destroy,:confirmEmail,:groupUser,:createGroup,:activate_inactivate,:inactivate,:activate] 
     has_permission_on [:settings], :to => [:index, :create]
     has_permission_on [:subjects], :to => [:index,:new,:create,:edit,:update,:destroy,:add_subject_category,:cs]
     has_permission_on [:questions], :to => [:viewQuestion,:checkMark,:index,:new,:question_type_listing,:create,:edit,:update,:destroy,:delete_option,:delete_match_option,:delete_matrix_row,:delete_matrix_column,:delete_hrcl_option,:saveImage,:publish_unpublish,:unpublish,:share,:sharewithCategory]
     has_permission_on [:exams], :to => [:delete_evaluator,:evaluator,:getEvaluator,:assignEvaluator,:getCategoryexams,:finishEvaluation,:manualEvaluation,:getExamQuestions,:evaluate,:showEvaluationtype,:hideEvaluationtype,:getExam,:index,:new,:create,:edit,:update,:destroy,:scheduleExam,:selectQuestion,:assignQustions,:selectExaminee,:assignExaminees,:previewExam,:deleteExamQuestion,:deleteExamUser,:getMark,:assignExam,:groupExam,:updateMark,:examtype,:create_examtype,:listExamtypes,:editExamtype,:deleteExamtype,:updateExamtype]
     has_permission_on [:results], :to => [:index,:usersResult,:viewUserResult,:groupResult,:examsResult,:viewExamResult,:departmentResult,:viewDepartmentResult]
     has_permission_on [:reports], :to => [:fetchExam,:index,:userReport,:viewuserReport,:examReport,:viewexamReport,:generateUser,:userSubjectwise,:generateExamReport,:departmentReport,:viewDepartmentReport,:generateDepartmentReport,:viewDepartmentReportgraph,:highLevel,:reportYear,:overall,:specificDepartment,:departmentDetailed,:semesterDetailed,:pass_fail,:generatePassfail]
     has_permission_on [:feedback], :to => [:index,:assign,:unassign,:viewFeedback,:submitFeedback,:feedbackResponse,:viewfeedbackResponse]
     has_permission_on [:temporary_examinee], :to => [:index,:new,:create]
     has_permission_on [:emails], :to => [:index,:edit,:update]
     has_permission_on [:categories], :to => [:index,:create,:listCategories,:delete_category]
     has_permission_on [:category_titles], :to => [:index,:new,:create,:edit,:update,:destroy,:updateCategory,:deleteCategory]
     has_permission_on [:images], :to => [:index,:new,:create,:edit,:update,:destroy,:clientImage,:createClientimage]
     has_permission_on [:clientinfo], :to => [:index,:new,:create,:edit,:update,:destroy]
     has_permission_on [:aboutus], :to => [:index,:create]
   end  
   
   role :examiner do
     has_permission_on [:welcome], :to => [:user_management,:examiner_dashboard]
     has_permission_on [:users], :to => [:deleteUsersubject,:index, :show, :new, :create,:edit,:update,:confirmEmail,:groupUser,:createGroup] 
     has_permission_on [:settings], :to => [:index, :create]
     has_permission_on [:subjects], :to => [:index,:new,:create,:edit,:update,:destroy,:add_subject_category,:cs]
     has_permission_on [:questions], :to => [:viewQuestion,:checkMark,:index,:new,:question_type_listing,:create,:edit,:update,:destroy,:delete_option,:delete_match_option,:delete_matrix_row,:delete_matrix_column,:delete_hrcl_option,:saveImage,:publish_unpublish,:unpublish,:share,:sharewithCategory]
     has_permission_on [:exams], :to => [:delete_evaluator,:evaluator,:getEvaluator,:assignEvaluator,:getCategoryexams,:finishEvaluation,:manualEvaluation,:getExamQuestions,:evaluate,:showEvaluationtype,:hideEvaluationtype,:getExam,:index,:new,:create,:edit,:update,:destroy,:scheduleExam,:selectQuestion,:assignQustions,:selectExaminee,:assignExaminees,:previewExam,:deleteExamQuestion,:deleteExamUser,:getMark,:assignExam,:groupExam,:updateMark,:examtype,:create_examtype,:listExamtypes,:editExamtype,:deleteExamtype,:updateExamtype]
     has_permission_on [:results], :to => [:index,:usersResult,:viewUserResult,:groupResult,:examsResult,:viewExamResult,:departmentResult,:viewDepartmentResult]
     has_permission_on [:reports], :to => [:fetchExam,:index,:userReport,:viewuserReport,:examReport,:viewexamReport,:generateUser,:userSubjectwise,:generateExamReport,:departmentReport,:viewDepartmentReport,:generateDepartmentReport,:viewDepartmentReportgraph,:highLevel,:reportYear,:overall,:specificDepartment,:departmentDetailed,:semesterDetailed,:pass_fail,:generatePassfail]
     has_permission_on [:feedback], :to => [:index,:assign,:unassign,:viewFeedback,:submitFeedback,:feedbackResponse,:viewfeedbackResponse]
     has_permission_on [:temporary_examinee], :to => [:index,:new,:create]
     has_permission_on [:emails], :to => [:index,:edit,:update]
     has_permission_on [:categories], :to => [:index,:create,:listCategories,:delete_category]
     has_permission_on [:category_titles], :to => [:index,:new,:create,:edit,:update,:destroy,:updateCategory,:deleteCategory]
     has_permission_on [:images], :to => [:index,:new,:create,:edit,:update,:destroy]

   end
   
   role :questionsetter do
     has_permission_on [:welcome], :to => [:qsetter_dashboard]
     has_permission_on [:users], :to => [:index, :edit,:update,:confirmEmail]
     has_permission_on [:questions], :to => [:viewQuestion,:index,:new,:question_type_listing,:create,:edit,:update,:destroy,:delete_option,:delete_match_option,:delete_matrix_row,:delete_matrix_column,:delete_hrcl_option,:saveImage,:publish_unpublish,:unpublish,:share,:sharewithCategory]
     has_permission_on [:feedback], :to => [:index]
     has_permission_on [:exams], :to => [:getCategoryexams,:finishEvaluation,:manualEvaluation,:getExamQuestions,:evaluate,:showEvaluationtype,:hideEvaluationtype,:getExam]
     
   end
   
   role :examinee do
     has_permission_on [:welcome], :to => [:examinee_dashboard]
     has_permission_on [:users], :to => [:edit,:update,:confirmEmail]
     has_permission_on [:attend_exams], :to => [:index,:confirm_exam,:reject_exam,:examination,:instruction,:evaluation,:ramdomizeQuestions,:examComplete,:calculateScore,:completedExams,:pendingExams,:windowClose]
     has_permission_on [:results], :to => [:resultIndex,:index]
     has_permission_on [:feedback], :to => [:viewFeedback,:submitFeedback]
   end
 end