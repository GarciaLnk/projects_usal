import React, { useState } from "react";
import {
  TextInput,
  PasswordInput,
  Anchor,
  Paper,
  Title,
  Text,
  Container,
  Button,
} from "@mantine/core";
import { useNavigate } from "react-router-dom";
import { useForm } from "@mantine/form";

export function Login() {
  const navigate = useNavigate();

  const [errors, setErrors] = useState({
    fetchError: false,
    fetchErrorMsg: "",
  });

  const form = useForm({
    initialValues: {
      email: "",
      password: "",
    },
  });

  const handleSubmit = async (values: any) => {
    try {
      const res = await fetch("/api/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: values.email,
          password: values.password,
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

      navigate("/");
      navigate(0);
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
    <Container size={420} style={{ position: "relative", top: "40px" }}>
      <Title
        align="center"
        sx={(theme) => ({
          fontFamily: `Space Grotesk, ${theme.fontFamily}`,
          fontWeight: 900,
        })}
      >
        ¡Bienvenido de nuevo!
      </Title>
      <Text color="dimmed" size="sm" align="center" mt={5}>
        ¿Aun no tienes una cuenta?{" "}
        <Anchor<"a">
          href="#"
          size="sm"
          onClick={(event) => {
            event.preventDefault();
            navigate("/register");
          }}
        >
          Crear cuenta
        </Anchor>
      </Text>

      <Paper withBorder shadow="md" p={30} mt={30} radius="md">
        <form onSubmit={form.onSubmit((values) => handleSubmit(values))}>
          <TextInput
            label="Email"
            placeholder="tu@email.com"
            required
            {...form.getInputProps("email")}
          />
          <PasswordInput
            label="Contraseña"
            placeholder="Tu contraseña"
            required
            mt="md"
            {...form.getInputProps("password")}
          />
          <Button type="submit" fullWidth mt="xl">
            Iniciar sesión
          </Button>
        </form>
        {errors.fetchError && (
          <Text style={{ color: "#e03131", paddingTop: "10px" }}>{errors.fetchErrorMsg}</Text>
        )}
      </Paper>
    </Container>
  );
}
