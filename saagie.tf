resource "kubernetes_deployment" "saagie" { 

  metadata { 

    name      = "saagie" 

    namespace = "default" 

  } 

  spec { 

    replicas = 1 

    selector { 

      match_labels = { 

        app = "saagie" 

      } 

    } 

    template { 

      metadata { 

        labels = { 

          app = "saagie" 

        } 

      } 

      spec { 

        container { 

          #image = "saagie:${var.wordpress_tag}" 

          name  = "saagie" 

          port { 

            container_port = 80 

          } 
          } 

        } 

      } 

    } 

  } 

 



resource "kubernetes_service" "saagie" { 

  metadata { 

    name      = "saagie" 

    namespace = "default" 

  } 

  spec { 

    selector = { 

      app = kubernetes_deployment.saagie.spec.0.template.0.metadata.0.labels.app 

    } 

    type = "ClusterIP" 

    port { 

      port        = 80 

      target_port = 80 

    } 

  } 

} 