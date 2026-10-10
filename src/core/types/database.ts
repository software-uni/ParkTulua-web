export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      asignacion_parqueadero: {
        Row: {
          created_at: string
          estado: string
          id: string
          parqueadero_id: string
          rol: string
          usuario_id: string
        }
        Insert: {
          created_at?: string
          estado?: string
          id?: string
          parqueadero_id: string
          rol: string
          usuario_id: string
        }
        Update: {
          created_at?: string
          estado?: string
          id?: string
          parqueadero_id?: string
          rol?: string
          usuario_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "asignacion_parqueadero_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "asignacion_parqueadero_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      calificacion: {
        Row: {
          comentario: string | null
          created_at: string
          estancia_id: string
          id: string
          valoracion: number
        }
        Insert: {
          comentario?: string | null
          created_at?: string
          estancia_id: string
          id?: string
          valoracion: number
        }
        Update: {
          comentario?: string | null
          created_at?: string
          estancia_id?: string
          id?: string
          valoracion?: number
        }
        Relationships: [
          {
            foreignKeyName: "calificacion_estancia_id_fkey"
            columns: ["estancia_id"]
            isOneToOne: true
            referencedRelation: "estancia"
            referencedColumns: ["id"]
          },
        ]
      }
      codigo_verificacion: {
        Row: {
          activado_en: string | null
          estado: string
          estancia_id: string | null
          expira_en: string | null
          generado_en: string
          id: string
          parqueadero_id: string
          proposito: string
          reserva_id: string | null
          usado_en: string | null
          verificador_hash: string
        }
        Insert: {
          activado_en?: string | null
          estado?: string
          estancia_id?: string | null
          expira_en?: string | null
          generado_en?: string
          id?: string
          parqueadero_id: string
          proposito: string
          reserva_id?: string | null
          usado_en?: string | null
          verificador_hash: string
        }
        Update: {
          activado_en?: string | null
          estado?: string
          estancia_id?: string | null
          expira_en?: string | null
          generado_en?: string
          id?: string
          parqueadero_id?: string
          proposito?: string
          reserva_id?: string | null
          usado_en?: string | null
          verificador_hash?: string
        }
        Relationships: [
          {
            foreignKeyName: "codigo_estancia_coherente"
            columns: ["estancia_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "estancia"
            referencedColumns: ["id", "parqueadero_id"]
          },
          {
            foreignKeyName: "codigo_reserva_coherente"
            columns: ["reserva_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "reserva"
            referencedColumns: ["id", "parqueadero_id"]
          },
          {
            foreignKeyName: "codigo_verificacion_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
        ]
      }
      estancia: {
        Row: {
          estado: string
          hora_entrada: string
          hora_salida: string | null
          id: string
          numero_ficha: string | null
          parqueadero_id: string
          registrada_por_usuario_id: string | null
          reserva_id: string | null
          usuario_id: string | null
          valor_parqueo_generado: number | null
          vehiculo_id: string
        }
        Insert: {
          estado?: string
          hora_entrada?: string
          hora_salida?: string | null
          id?: string
          numero_ficha?: string | null
          parqueadero_id: string
          registrada_por_usuario_id?: string | null
          reserva_id?: string | null
          usuario_id?: string | null
          valor_parqueo_generado?: number | null
          vehiculo_id: string
        }
        Update: {
          estado?: string
          hora_entrada?: string
          hora_salida?: string | null
          id?: string
          numero_ficha?: string | null
          parqueadero_id?: string
          registrada_por_usuario_id?: string | null
          reserva_id?: string | null
          usuario_id?: string | null
          valor_parqueo_generado?: number | null
          vehiculo_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "estancia_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "estancia_registrada_por_usuario_id_fkey"
            columns: ["registrada_por_usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "estancia_reserva_coherente"
            columns: ["reserva_id", "parqueadero_id", "vehiculo_id"]
            isOneToOne: false
            referencedRelation: "reserva"
            referencedColumns: ["id", "parqueadero_id", "vehiculo_id"]
          },
          {
            foreignKeyName: "estancia_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "estancia_vehiculo_id_fkey"
            columns: ["vehiculo_id"]
            isOneToOne: false
            referencedRelation: "vehiculo"
            referencedColumns: ["id"]
          },
        ]
      }
      intento_validacion: {
        Row: {
          codigo_id: string | null
          created_at: string
          estancia_id: string | null
          id: string
          parqueadero_id: string
          proposito: string
          reserva_id: string | null
          resultado: string
          validador_usuario_id: string | null
        }
        Insert: {
          codigo_id?: string | null
          created_at?: string
          estancia_id?: string | null
          id?: string
          parqueadero_id: string
          proposito: string
          reserva_id?: string | null
          resultado: string
          validador_usuario_id?: string | null
        }
        Update: {
          codigo_id?: string | null
          created_at?: string
          estancia_id?: string | null
          id?: string
          parqueadero_id?: string
          proposito?: string
          reserva_id?: string | null
          resultado?: string
          validador_usuario_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "intento_codigo_coherente"
            columns: ["codigo_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "codigo_verificacion"
            referencedColumns: ["id", "parqueadero_id"]
          },
          {
            foreignKeyName: "intento_estancia_coherente"
            columns: ["estancia_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "estancia"
            referencedColumns: ["id", "parqueadero_id"]
          },
          {
            foreignKeyName: "intento_reserva_coherente"
            columns: ["reserva_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "reserva"
            referencedColumns: ["id", "parqueadero_id"]
          },
          {
            foreignKeyName: "intento_validacion_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "intento_validacion_validador_usuario_id_fkey"
            columns: ["validador_usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      pago: {
        Row: {
          created_at: string
          estado: string
          estancia_id: string | null
          id: string
          moneda: string
          monto: number
          parqueadero_id: string
          referencia_externa: string
          reserva_id: string | null
        }
        Insert: {
          created_at?: string
          estado?: string
          estancia_id?: string | null
          id?: string
          moneda?: string
          monto: number
          parqueadero_id: string
          referencia_externa: string
          reserva_id?: string | null
        }
        Update: {
          created_at?: string
          estado?: string
          estancia_id?: string | null
          id?: string
          moneda?: string
          monto?: number
          parqueadero_id?: string
          referencia_externa?: string
          reserva_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pago_estancia_coherente"
            columns: ["estancia_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "estancia"
            referencedColumns: ["id", "parqueadero_id"]
          },
          {
            foreignKeyName: "pago_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pago_reserva_coherente"
            columns: ["reserva_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "reserva"
            referencedColumns: ["id", "parqueadero_id"]
          },
        ]
      }
      parqueadero: {
        Row: {
          created_at: string
          direccion: string
          id: string
          latitud: number
          longitud: number
          nombre: string
        }
        Insert: {
          created_at?: string
          direccion: string
          id?: string
          latitud: number
          longitud: number
          nombre: string
        }
        Update: {
          created_at?: string
          direccion?: string
          id?: string
          latitud?: number
          longitud?: number
          nombre?: string
        }
        Relationships: []
      }
      parqueadero_tipo_vehiculo: {
        Row: {
          activo: boolean
          capacidad: number
          created_at: string
          cupos_reservables: number
          id: string
          parqueadero_id: string
          tarifa_hora: number | null
          tipo_vehiculo_id: string
        }
        Insert: {
          activo?: boolean
          capacidad: number
          created_at?: string
          cupos_reservables?: number
          id?: string
          parqueadero_id: string
          tarifa_hora?: number | null
          tipo_vehiculo_id: string
        }
        Update: {
          activo?: boolean
          capacidad?: number
          created_at?: string
          cupos_reservables?: number
          id?: string
          parqueadero_id?: string
          tarifa_hora?: number | null
          tipo_vehiculo_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "parqueadero_tipo_vehiculo_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "parqueadero_tipo_vehiculo_tipo_vehiculo_id_fkey"
            columns: ["tipo_vehiculo_id"]
            isOneToOne: false
            referencedRelation: "tipo_vehiculo"
            referencedColumns: ["id"]
          },
        ]
      }
      reserva: {
        Row: {
          cancelada_en: string | null
          cancelada_por_usuario_id: string | null
          created_at: string
          duracion_estimada_min: number
          estado: string
          id: string
          parqueadero_id: string
          usuario_id: string | null
          vehiculo_id: string
          vence_en: string
        }
        Insert: {
          cancelada_en?: string | null
          cancelada_por_usuario_id?: string | null
          created_at?: string
          duracion_estimada_min: number
          estado?: string
          id?: string
          parqueadero_id: string
          usuario_id?: string | null
          vehiculo_id: string
          vence_en: string
        }
        Update: {
          cancelada_en?: string | null
          cancelada_por_usuario_id?: string | null
          created_at?: string
          duracion_estimada_min?: number
          estado?: string
          id?: string
          parqueadero_id?: string
          usuario_id?: string | null
          vehiculo_id?: string
          vence_en?: string
        }
        Relationships: [
          {
            foreignKeyName: "reserva_cancelada_por_usuario_id_fkey"
            columns: ["cancelada_por_usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reserva_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reserva_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reserva_vehiculo_id_fkey"
            columns: ["vehiculo_id"]
            isOneToOne: false
            referencedRelation: "vehiculo"
            referencedColumns: ["id"]
          },
        ]
      }
      servicio: {
        Row: {
          activo: boolean
          created_at: string
          duracion_estimada_min: number | null
          id: string
          nombre: string
          parqueadero_id: string
          precio: number
        }
        Insert: {
          activo?: boolean
          created_at?: string
          duracion_estimada_min?: number | null
          id?: string
          nombre: string
          parqueadero_id: string
          precio: number
        }
        Update: {
          activo?: boolean
          created_at?: string
          duracion_estimada_min?: number | null
          id?: string
          nombre?: string
          parqueadero_id?: string
          precio?: number
        }
        Relationships: [
          {
            foreignKeyName: "servicio_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
        ]
      }
      servicio_solicitado: {
        Row: {
          created_at: string
          estado: string
          estancia_id: string | null
          id: string
          parqueadero_id: string
          precio_pactado: number
          reserva_id: string | null
          servicio_id: string
        }
        Insert: {
          created_at?: string
          estado?: string
          estancia_id?: string | null
          id?: string
          parqueadero_id: string
          precio_pactado: number
          reserva_id?: string | null
          servicio_id: string
        }
        Update: {
          created_at?: string
          estado?: string
          estancia_id?: string | null
          id?: string
          parqueadero_id?: string
          precio_pactado?: number
          reserva_id?: string | null
          servicio_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "servicio_solicitado_estancia_coherente"
            columns: ["estancia_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "estancia"
            referencedColumns: ["id", "parqueadero_id"]
          },
          {
            foreignKeyName: "servicio_solicitado_parqueadero_id_fkey"
            columns: ["parqueadero_id"]
            isOneToOne: false
            referencedRelation: "parqueadero"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "servicio_solicitado_reserva_coherente"
            columns: ["reserva_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "reserva"
            referencedColumns: ["id", "parqueadero_id"]
          },
          {
            foreignKeyName: "servicio_solicitado_servicio_coherente"
            columns: ["servicio_id", "parqueadero_id"]
            isOneToOne: false
            referencedRelation: "servicio"
            referencedColumns: ["id", "parqueadero_id"]
          },
        ]
      }
      tipo_vehiculo: {
        Row: {
          activo: boolean
          codigo: string
          created_at: string
          id: string
          nombre: string
          requiere_placa: boolean
        }
        Insert: {
          activo?: boolean
          codigo: string
          created_at?: string
          id?: string
          nombre: string
          requiere_placa: boolean
        }
        Update: {
          activo?: boolean
          codigo?: string
          created_at?: string
          id?: string
          nombre?: string
          requiere_placa?: boolean
        }
        Relationships: []
      }
      usuario: {
        Row: {
          correo: string | null
          created_at: string
          firebase_uid: string | null
          id: string
          nombre_completo: string | null
        }
        Insert: {
          correo?: string | null
          created_at?: string
          firebase_uid?: string | null
          id?: string
          nombre_completo?: string | null
        }
        Update: {
          correo?: string | null
          created_at?: string
          firebase_uid?: string | null
          id?: string
          nombre_completo?: string | null
        }
        Relationships: []
      }
      usuario_vehiculo: {
        Row: {
          activo: boolean
          created_at: string
          usuario_id: string
          vehiculo_id: string
        }
        Insert: {
          activo?: boolean
          created_at?: string
          usuario_id: string
          vehiculo_id: string
        }
        Update: {
          activo?: boolean
          created_at?: string
          usuario_id?: string
          vehiculo_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "usuario_vehiculo_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "usuario_vehiculo_vehiculo_id_fkey"
            columns: ["vehiculo_id"]
            isOneToOne: false
            referencedRelation: "vehiculo"
            referencedColumns: ["id"]
          },
        ]
      }
      vehiculo: {
        Row: {
          created_at: string
          id: string
          placa: string | null
          tipo_vehiculo_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          placa?: string | null
          tipo_vehiculo_id: string
        }
        Update: {
          created_at?: string
          id?: string
          placa?: string | null
          tipo_vehiculo_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vehiculo_tipo_vehiculo_id_fkey"
            columns: ["tipo_vehiculo_id"]
            isOneToOne: false
            referencedRelation: "tipo_vehiculo"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      es_cuenta_con_registro: { Args: never; Returns: boolean }
      parqueaderos_del_personal: { Args: never; Returns: string[] }
      usuario_actual_id: { Args: never; Returns: string }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const
