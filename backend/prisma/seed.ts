import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // 1. Czyszczenie starych danych
  await prisma.entry.deleteMany();
  await prisma.category.deleteMany();
  await prisma.user.deleteMany();

  // 2. Tworzenie użytkownika
  const user = await prisma.user.create({
    data: {
      login: 'ola',
      email: 'ola@a.pl',
      password: '123abc',
    },
  });

  // 3. Tworzenie kategorii
  const category = await prisma.category.create({
    data: {
      name: 'Fits',
      userId: user.id,
    },
  });

  // 4. Tworzenie wpisu w pamiętniku
  const entry = await prisma.entry.create({
    data: {
      title: 'First Entry',
      content: 'I hope it works!',
      userId: user.id,
      categoryId: category.id,
    },
  });

  console.log('Seedowanie bazy danych zakończone sukcesem!');
  console.log({ user, category, entry });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });