(use gauche.test)
(test-start "parameterize-pitfalls")


(test-section "parameterize-1")
(load "./parameterize-1")

(include "./test-include")
(test-1a-basic)
(test-1b-restart 'bad)


(test-section "parameterize-2")
(load "./parameterize-2")

(include "./test-include")
(test-1a-basic)
(test-1b-restart 'ok)
(test-2a-set+restart 'bad)


(test-section "parameterize-3")
(load "./parameterize-3")

(include "./test-include")
(test-1a-basic)
(test-1b-restart 'ok)
(test-2a-set+restart 'ok)


(test-section "parameterize-4")
(load "./parameterize-4")

(include "./test-include")
(test-1a-basic)
(test-1b-restart 'ok)
(test-2a-set+restart 'ok)
(test-4a-converter)
(test-4b-converter 'bad)


(test-section "parameterize-5")
(load "./parameterize-5")

(include "./test-include")
(test-1a-basic)
(test-1b-restart 'ok)
(test-2a-set+restart 'ok)
(test-4a-converter)
(test-4b-converter 'ok)
(test-5a-rollback 'bad)


(test-section "parameterize-6")
(load "./parameterize-6")

(include "./test-include")
(test-1a-basic)
(test-1b-restart 'ok)
(test-2a-set+restart 'ok)
(test-4a-converter)
(test-4b-converter 'ok)
(test-5a-rollback 'ok)




(test-end)

       

  
