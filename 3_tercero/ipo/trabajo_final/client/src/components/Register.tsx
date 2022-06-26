import React, { useState } from "react";
import {
  TextInput,
  PasswordInput,
  Paper,
  Title,
  Container,
  Button,
  Text,
} from "@mantine/core";
import { useForm } from "@mantine/form";
import { useNavigate } from "react-router-dom";

export function Register() {
  const navigate = useNavigate();

  const [errors, setErrors] = useState({
    fetchError: false,
    fetchErrorMsg: "",
  });

  const form = useForm({
    initialValues: {
      name: "",
      email: "",
      password: "",
      password2: "",
    },

    validate: (values) => ({
      email: /^\S+@\S+$/.test(values.email) ? null : "Correo no válido",
      password: /.{8,}/.test(values.password)
        ? null
        : "La contraseña debe tener al menos 8 caracteres",
      password2:
        values.password2 === values.password
          ? null
          : "Las contraseñas no coinciden",
    }),
  });

  const handleSubmit = async (values: any) => {
    try {
      const res = await fetch("/api/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: values.name,
          email: values.email,
          password: values.password,
          password2: values.password2,
        }),
      });

      if (!res.ok) {
        const error = await res.text();
        return setErrors({
          ...errors,
          fetchError: true,
          fetchErrorMsg: error,
        });
      }

      const data = await res.text();
      setErrors({
        ...errors,
        fetchError: true,
        fetchErrorMsg: data,
      });

      navigate("/login");
    } catch (error) {
      setErrors({
        ...errors,
        fetchError: true,
        fetchErrorMsg:
          "There was a problem with our server, please try again later",
      });
    }
  };

  return (
    <Container size={420} style={{position:"relative",top: "40px"}}>
      <Title
        align="center"
        sx={(theme) => ({
          fontFamily: `Space Grotesk, ${theme.fontFamily}`,
          fontWeight: 900,
        })}
      >
        ¡Bienvenido!
      </Title>

      <Paper withBorder shadow="md" p={30} mt={30} radius="md">
        <form onSubmit={form.onSubmit((values) => handleSubmit(values))}>
          <TextInput
            label="Nombre"
            placeholder="Juan García"
            required
            {...form.getInputProps("name")}
          />
          <TextInput
            label="Email"
            placeholder="tu@email.com"
            required
            {...form.getInputProps("email")}
          />
          <PasswordInput
            label="Contraseña"
            placeholder="Contraseña de más de 8 caracteres"
            required
            mt="md"
            {...form.getInputProps("password")}
          />
          <PasswordInput
            label="Repite la contraseña"
            placeholder="Introduce la contraseña de nuevo"
            required
            mt="md"
            {...form.getInputProps("password2")}
          />
          <Button type="submit" fullWidth mt="xl">
            Crear cuenta
          </Button>
        </form>
        {errors.fetchError && (
          <Text style={{ color: "#e03131", paddingTop: "10px" }}>{errors.fetchErrorMsg}</Text>
        )}
      </Paper>
    </Container>
  );
}
